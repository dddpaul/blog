+++
date = "2016-08-30T17:45:00+03:00"
draft = false
title = "Simple Netcat tool written in Go"
tags = ["golang", "linux"]

+++

It's spectacularly simple to implement TCP Netcat in Go thanks to [io.Copy](https://golang.org/pkg/io/#Copy).

{{< highlight go >}}
type Progress struct {
	bytes uint64
}

func TransferStreams(con net.Conn) {
	c := make(chan Progress)

	// Read from Reader and write to Writer until EOF
	copy := func(r io.ReadCloser, w io.WriteCloser) {
		defer func() {
			r.Close()
			w.Close()
		}()
		n, _ := io.Copy(w, r)
		c <- Progress{bytes: uint64(n)}
	}

	go copy(con, os.Stdout)
	go copy(os.Stdin, con)

	p := <-c
	log.Printf("[%s]: Connection has been closed by remote peer, %d bytes has been received\n", con.RemoteAddr(), p.bytes)
	p = <-c
	log.Printf("[%s]: Local peer has been stopped, %d bytes has been sent\n", con.RemoteAddr(), p.bytes)
}
{{< /highlight >}}

But it's much more harder to do the same for UDP. UDP is connectionless so there is no "streams" that can be copied. You must tediously read data from connection to buffer and write this buffer to stdout by one goroutine. And read data from stdin and write it to connection from other goroutine.

Some remarks:

* Without streams there is no EOF so we must use some predefined disconnect sequence to terminate transfer.
* Without established connection a listener doesn't know the remote peer address until actual data will be received. So listener must wait for data, then read this data and remote address with [*net.UDPConn.ReadFrom](https://golang.org/pkg/net/#UDPConn.ReadFrom).

{{< highlight go >}}

const (
	// BufferLimit specifies buffer size that is sufficient to
	// handle full-size UDP datagram or TCP segment in one step
	BufferLimit = 2<<16 - 1
	// DisconnectSequence is used to disconnect UDP sessions
	DisconnectSequence = "~."
)

// Progress indicates transfer status
type Progress struct {
	remoteAddr net.Addr
	bytes      uint64
}

func TransferPackets(con net.Conn) {
	c := make(chan Progress)

	// Read from Reader and write to Writer until EOF.
	// ra is an address to whom packets must be sent in listen mode.
	copy := func(r io.ReadCloser, w io.WriteCloser, ra net.Addr) {
		defer func() {
			r.Close()
			w.Close()
		}()

		buf := make([]byte, BufferLimit)
		bytes := uint64(0)
		var n int
		var err error
		var addr net.Addr

		for {
			// Read
			if con, ok := r.(*net.UDPConn); ok {
				n, addr, err = con.ReadFrom(buf)
				// In listen mode remote address is unknown until read from
				// connection. Inform caller function with this address.
				if con.RemoteAddr() == nil && ra == nil {
					ra = addr
					c <- Progress{remoteAddr: ra}
				}
			} else {
				n, err = r.Read(buf)
			}
			if err != nil {
				if err != io.EOF {
					log.Printf("[%s]: ERROR: %s\n", ra, err)
				}
				break
			}
			if string(buf[0:n-1]) == DisconnectSequence {
				break
			}

			// Write
			if con, ok := w.(*net.UDPConn); ok && con.RemoteAddr() == nil {
				// Connection remote address must be nil otherwise
				// "WriteTo with pre-connected connection" will be thrown
				n, err = con.WriteTo(buf[0:n], ra)
			} else {
				n, err = w.Write(buf[0:n])
			}
			if err != nil {
				log.Printf("[%s]: ERROR: %s\n", ra, err)
				break
			}
			bytes += uint64(n)
		}
		c <- Progress{bytes: bytes}
	}

	ra := con.RemoteAddr()
	go copy(con, os.Stdout, ra)
	// If connection hasn't got remote address then wait for it from receiver goroutine
	if ra == nil {
		p := <-c
		ra = p.remoteAddr
		log.Printf("[%s]: Datagram has been received\n", ra)
	}
	go copy(os.Stdin, con, ra)

	p := <-c
	log.Printf("[%s]: Connection has been closed, %d bytes has been received\n", ra, p.bytes)
	p = <-c
	log.Printf("[%s]: Local peer has been stopped, %d bytes has been sent\n", ra, p.bytes)
}
{{< /highlight >}}

Links:

* [Simple Netcat tool written in Go (gonc)](https://github.com/dddpaul/gonc) - gonc Github project
* [Implementing UDP vs TCP in Golang](http://www.minaandrawos.com/2016/05/14/udp-vs-tcp-in-golang/) - Golang TCP/UDP tips and tricks
* [Golang bits and pieces: IO with readers and writers](https://betabug.nl/golang-bits-and-pieces-io-with-readers-and-writers/) - Readers and Writers everywhere
* [Go Walkthrough: io package](https://medium.com/@benbjohnson/go-walkthrough-io-package-8ac5e95a9fbd) - Tips and bits of Go io package
* [Разбираемся в Go: пакет io](https://habrahabr.ru/post/306914/) - Previous article translated 
* [Simple netcat on go](https://github.com/yanzay/netcat) - Another Netcat implementation
* [TCP Puzzlers](https://www.joyent.com/blog/tcp-puzzlers) - TCP connection tricky parts
