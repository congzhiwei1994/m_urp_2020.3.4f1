
// 观察者模式练习

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ObserverPattern : MonoBehaviour
{
    Cat cat0 = new Cat("加菲猫", "黄色");
    Cat cat1 = new Cat("加菲猫2", "hong色");
    Mouse mouse1 = new Mouse("米奇", "黑色");
    Mouse mouse2 = new Mouse("唐老鸭", "白色");

    private void Awake()
    {

    }
    private void Start()
    {
        // 注册事件
        // cat0.catComedlg += mouse1.RunAway;
        // cat1.catComedlg += mouse2.RunAway;
        mouse1.Watch(cat0);
        mouse2.Watch(cat1);
        mouse1.CancelWatch(cat0);
        // 猫的状态发生改变
        cat0.CatComing();
    }
}
