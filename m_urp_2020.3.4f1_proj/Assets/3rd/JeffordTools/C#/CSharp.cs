using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jefford.Csharp
{
    public class CSharp : MonoBehaviour
    {
        Enemy m_enemy;
        Boss m_boss;
        [ContextMenu("测试", false, 0)]
        void Test()
        {
            m_boss = new Boss();
        }

    }

}
