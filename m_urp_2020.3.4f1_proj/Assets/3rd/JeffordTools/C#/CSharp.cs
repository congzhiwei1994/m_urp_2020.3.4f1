using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jefford.Csharp
{
    public class CSharp : MonoBehaviour
    {
        MyString m_string = new MyString();
        [ContextMenu("测试", false, 0)]
        void Test()
        {
            m_string.StringTest();
        }

    }

}
