using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 结构函数

namespace Jefford.Csharp
{
    public struct MyStruct
    {
        public string firstName;
        public string lastName;

        public void MyName()
        {
            var myname = "我的名字" + ":  " + firstName + lastName;
            Debug.LogError(myname);
        }
    }
    public class StuctFunction
    {
        public void Fun1(MyStruct m_struct)
        {
            var Myname = "我的名字" + ":  " + m_struct.firstName + m_struct.lastName;
            Debug.LogError(Myname);
        }
    }

}
