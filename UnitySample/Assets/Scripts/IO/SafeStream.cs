using UnityEngine;
using System.Collections;
using System.IO;
using System;

/// <summary>
/// No exception stream
/// </summary>
public class SafeStream
{
    private readonly Stream mStream;

    public SafeStream(Stream stream)
    {
        mStream = stream;
    }

    /// <summary>
    /// When overridden in a derived class, sets the position within the current stream.
    /// </summary>
    /// 
    /// <returns>       
    /// If successful, the function returns true.
    /// Otherwise, it returns false.
    /// </returns>
    /// <param name="offset">A byte offset relative to the <paramref name="origin"/> parameter. </param><param name="origin">A value of type <see cref="T:System.IO.SeekOrigin"/> indicating the reference point used to obtain the new position. </param><filterpriority>1</filterpriority>
    public bool Seek(long offset, SeekOrigin origin)
    {
        try
        {
            mStream.Seek(offset, origin);
            return true;
        }
        catch (Exception)
        {
            return false;
        }
    }

    /// <summary>
    /// When overridden in a derived class, sets the length of the current stream.
    /// </summary>
    /// <param name="value">The desired length of the current stream in bytes. </param><filterpriority>2</filterpriority>
    public void SetLength(long value)
    {
        try
        {
            mStream.SetLength(value);
        }
        catch (Exception)
        {
            // ignored
        }
    }

    /// <summary>
    /// When overridden in a derived class, reads a sequence of bytes from the current stream and advances the position within the stream by the number of bytes read.
    /// </summary>
    /// 
    /// <returns>
    /// The total number of bytes read into the buffer. This can be less than the number of bytes requested if that many bytes are not currently available, or zero (0) if the end of the stream has been reached.
    /// </returns>
    /// <param name="buffer">An array of bytes. When this method returns, the buffer contains the specified byte array with the values between <paramref name="offset"/> and (<paramref name="offset"/> + <paramref name="count"/> - 1) replaced by the bytes read from the current source. </param><param name="offset">The zero-based byte offset in <paramref name="buffer"/> at which to begin storing the data read from the current stream. </param><param name="count">The maximum number of bytes to be read from the current stream. </param><filterpriority>1</filterpriority>
    public int Read(byte[] buffer, int offset, int count)
    {
        try
        {
            return mStream.Read(buffer, offset, count);
        }
        catch (Exception)
        {
            return 0;
        }
    }

    /// <summary>
    /// When overridden in a derived class, writes a sequence of bytes to the current stream and advances the current position within this stream by the number of bytes written.
    /// </summary>
    /// <param name="buffer">An array of bytes. This method copies <paramref name="count"/> bytes from <paramref name="buffer"/> to the current stream. </param><param name="offset">The zero-based byte offset in <paramref name="buffer"/> at which to begin copying bytes to the current stream. </param><param name="count">The number of bytes to be written to the current stream. </param><filterpriority>1</filterpriority>
    public bool Write(byte[] buffer, int offset, int count)
    {
        try
        {
            mStream.Write(buffer, offset, count);
            return true;
        }
        catch (Exception)
        {
            return false;
        }
    }

    /// <summary>
    /// When overridden in a derived class, clears all buffers for this stream and causes any buffered data to be written to the underlying device.
    /// </summary>
    public void Flush()
    {
        try
        {
            mStream.Flush();
        }
        catch (Exception)
        {
            // ignored
        }
    }

    /// <summary>
    /// Gets the current position of this stream.
    /// </summary>
    /// 
    /// <returns>
    /// The current position of this stream.
    /// </returns>
    public long Tell()
    {
        try
        {
            return mStream.Position;
        }
        catch (Exception)
        {
            return -1;
        }
    }

    /// <summary>
    /// Closes the current stream and releases any resources (such as sockets and file handles) associated with the current stream.
    /// </summary>
    /// <filterpriority>1</filterpriority>
    public void Close()
    {
        mStream.Close();
    }

    /// <summary>
    /// When overridden in a derived class, gets the length in bytes of the stream.
    /// </summary>
    /// 
    /// <returns>
    /// A long value representing the length of the stream in bytes.
    /// </returns>
    public long Length
    {
        get
        {
            try
            {
                return mStream.Length;
            }
            catch (Exception)
            {
                return -1;
            }
        }
    }

    /// <summary>
    /// Set the end of stream, this was if the stream was
    /// larger before its size will be properly reduced.
    /// </summary>
    public void SetEndOfStream()
    {
        try
        {
            mStream.SetLength(mStream.Position);
        }
        catch (Exception)
        {
            // ignored
        }
    }
}
