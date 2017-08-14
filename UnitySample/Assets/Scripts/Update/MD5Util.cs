using UnityEngine;
using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

public class MD5Util : Celf.Singleton<MD5Util>
{
    public static  string GetFileMD5(string fullPath)
    {
        if (string.IsNullOrEmpty(fullPath))
        {
            return "";
        }

        try
        {
            FileStream fs = new FileStream(fullPath, FileMode.Open);
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] retVal = md5.ComputeHash(fs);
            fs.Close();

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < retVal.Length; i++)
            {
                sb.Append(retVal[i].ToString("x2"));
            }

            return sb.ToString();
        }
        catch (Exception ex)
        {
            throw new Exception("GetFileMD5() fail, error:" + ex.Message);
        }
    }

    public static string GetStringMD5Hash(MD5 md5Hash, string input)
    {
        try
        {
            //Convert the input string to a byte array and compute the hash.
            byte[] data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input));

            //Create a new StringBuilder to collect the bytes and create a string.
            StringBuilder builder = new StringBuilder();

            //Loop through each byte of the hashed data and format each one as a hexadecimal strings.
            for (int cnt = 0; cnt < data.Length; cnt++)
            {
                builder.Append(data[cnt].ToString("x2"));
            }

            //Return the hexadecimal string
            return builder.ToString();
        }
        catch (Exception ex)
        {
            throw new Exception("GetMD5Hash() fail, error:" + ex.Message);
        }

    }

    public static bool VerifyMD5Hash(MD5 md5Hash, string input, string hash)
    {
        //Hash the input
        string hashOfInput = GetStringMD5Hash(md5Hash, input);

        //Create a StringComparer to compare the hashes.
        StringComparer comparer = StringComparer.OrdinalIgnoreCase;

        return 0 == comparer.Compare(hashOfInput, hash);
    }
}