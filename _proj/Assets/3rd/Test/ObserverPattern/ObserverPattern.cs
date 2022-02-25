
// 观察者模式练习

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ObserverPattern : MonoBehaviour
{
    Cat cat1; Mouse mouse1;
    Mouse mouse2;

    private void Awake()
    {
        cat1 = new Cat("加菲猫", "黄色");

        mouse1 = new Mouse("米奇", "黑色", cat1);
        mouse2 = new Mouse("唐老鸭", "白色", cat1);
        cat1.CatComing();

    }
    private void Start()
    {

    }
}
