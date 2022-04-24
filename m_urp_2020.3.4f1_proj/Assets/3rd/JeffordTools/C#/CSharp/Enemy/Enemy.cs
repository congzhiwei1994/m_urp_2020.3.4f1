
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
        private int x;

        // 父类无参的构造方法
        public Enemy()
        {
            Debug.LogError("父类Enemy的无参构造函数");
        }

        // 父类有参的构造方法
        public Enemy(int value)
        {
            x = value;
            Debug.LogError(x);
        }
    }

}
