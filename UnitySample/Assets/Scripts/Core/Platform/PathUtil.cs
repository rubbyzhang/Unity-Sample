using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Text;

public class PathUtil 
{
    /**
    * Convert a path name by converting to all lower case and changing '\' to '/'
    */
    public static string NormalizePath(string fileName)
    {
        if (string.IsNullOrEmpty(fileName))
        {
            return "";
        }

        StringBuilder str = new StringBuilder();
        int length = fileName.Length;
        for (int iChar = 0; iChar < length; ++iChar)
        {
            char c = fileName[iChar];
            if (c == '\\')
            {
                c = '/';
            }
            if (c == '/')
            {
                // 此处会考虑前一个字符是否仍然为'/', 如果是则不重复添加
                if (str.Length == 0 || (str[str.Length - 1] != '/'))
                {
                    str.Append(c);
                }
            }
            else
            {
                str.Append(char.ToLower(c));
            }
        }

        str.Replace("/./", "/");
        return str.ToString();
    }

    /// <summary>
    /// Unique the path list
    /// </summary>
    /// <param name="paths"></param>
    public static void UniquePaths(List<string> paths)
    {
        paths.Sort();

        int last = paths.Count;
        int first = 0;
        for (int firstb; (firstb = first) != last && ++first != last; )
        {
            if (paths[firstb] == paths[first])
            {	
                // copy down
                for (; ++first != last; )
                {
                    if (paths[firstb] != paths[first])
                    {
                        paths[++firstb] = paths[first];
                    }
                }
                ++firstb;
                paths.RemoveRange(firstb, last - firstb);
                return;
            }
        }
    }
}
