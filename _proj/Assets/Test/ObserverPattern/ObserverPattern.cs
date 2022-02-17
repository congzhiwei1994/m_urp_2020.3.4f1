
// 观察者模式练习

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ObserverPattern : MonoBehaviour
{
    Cat cat = new Cat("加菲猫", "黄色");
    Mouse mouse1 = new Mouse("米奇", "黑色");
    Mouse mouse2 = new Mouse("唐老鸭", "白色");
    private void Start()
    {
        // 注册事件
        cat.catComedlg += mouse1.RunAway;
        cat.catComedlg += mouse2.RunAway;
        // 猫的状态发生改变
        cat.CatComing();
    }
}
