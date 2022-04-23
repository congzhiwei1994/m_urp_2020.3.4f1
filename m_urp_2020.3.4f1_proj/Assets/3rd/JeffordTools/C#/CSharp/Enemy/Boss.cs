
// 继承/ 派生类的构造函数

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jefford.Csharp
{
    /// <summary>
    /// 怪物
    /// </summary>
    public class Boss : Enemy
    {
        public Boss() : base()
        {
            Debug.LogError("子类的构造函数");
        }

    }

}
