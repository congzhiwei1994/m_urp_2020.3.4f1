using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace Jefford.Csharp
{
    public class CSharp : MonoBehaviour
    {
        public void Start()
        {
        }

        [ContextMenu("测试")]
        public void Test()
        {
            Mycalss _mycalss = new Mycalss();
            Debug.LogError("方法执行之前---" + _mycalss.val);

            ResAsParameter(_mycalss);

            Debug.LogError("方法执行之后---" + _mycalss.val);
        }

        public void ResAsParameter(Mycalss f1)
        {
            f1.val = 50;
            Debug.LogError("赋值之后----" + f1.val);

            f1 = new Mycalss();
            Debug.LogError("实例之后" + f1.val);
        }
    }

    public class Mycalss
    {
        public int val = 20;
    }
}