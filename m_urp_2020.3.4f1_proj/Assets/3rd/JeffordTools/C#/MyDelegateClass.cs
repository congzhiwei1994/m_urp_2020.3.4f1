using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jefford.Csharp
{
    public delegate void M_Delegate();
    public delegate int IntDelegate();
    public delegate void RefDelegate(ref int value);
    public class MyDelegateClass
    {
        public void DelegateFun01()
        {
            Debug.LogError("DelegateFun01");
        }
        public void DelegateFun02()
        {
            Debug.LogError("DelegateFun02");
        }

        public int DelIntFun01()
        {

            return 1;
        }
        public int DelIntFun02()
        {
            return 2;
        }
        public static int DelIntFun03()
        {
            return 200;
        }

        public void RefDelFun01(ref int value)
        {
            value += 5;
            Debug.LogError(value);
        }

    }
}

