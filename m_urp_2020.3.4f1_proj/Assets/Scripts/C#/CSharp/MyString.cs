//字符串

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jefford.Csharp
{
    public class MyString
    {
        // 获取字符串长度
        public int StringLength()
        {
            string _string = "Zhao";
            return _string.Length;
        }

        public void StringTest()
        {
            string _string = " Zhao   ";

            // 移除头部和尾部的空白字符
            string _string1 = _string.Trim();
            // Debug.LogError("移除前" + _string + "|" + "----" + "移除后" + _string1 + "|");

            // string _string = "Zhao";
            string[] _string2 = _string.Split('a');
            foreach (var item in _string2)
            {
                Debug.LogError(item);
            }
        }
    }
}

