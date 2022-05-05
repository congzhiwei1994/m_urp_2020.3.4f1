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
            m_gen = new Genericity<int>(1, 3);
            m_gen.GetSum();
        }

    }

}
