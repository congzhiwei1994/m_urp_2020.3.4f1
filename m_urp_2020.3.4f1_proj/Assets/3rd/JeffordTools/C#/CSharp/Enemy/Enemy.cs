
// 继承/ 派生类的构造函数

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jefford.Csharp
{
    /// <summary>
    /// 敌人
    /// </summary>
    public class Enemy
    {
        public Enemy()
        {
            Debug.LogError("父类Enemy的构造函数");
        }
    }

}
