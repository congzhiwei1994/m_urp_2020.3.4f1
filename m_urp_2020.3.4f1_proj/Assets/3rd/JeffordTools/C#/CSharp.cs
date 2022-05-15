using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jefford.Csharp
{
    public class CSharp : MonoBehaviour
    {
        Genericity<int> m_gen;


        [ContextMenu("测试", false, 0)]
        void Test()
        {
            int b = 1;
            b = Sum(ref b);
            Debug.LogError(b);
        }

        int Sum(ref int a)
        {
            return a + 2;
        }

    }

}
