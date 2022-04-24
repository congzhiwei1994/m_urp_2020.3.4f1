
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
        private int y;

        // base 可以不写默认调用父类构造函数
        public Boss() : base()
        {
            Debug.LogError("子类的无参构造函数");
        }

        // 子类有参的构造函数
        public Boss(int x, int y) : base(x)
        {
            this.y = y;
            Debug.LogError(y);
        }
    }

}
