using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 被观察者类
/// </summary>
public class Cat
{
    private string name;
    private string color;
    public CatComedlg catComedlg;

    public Cat(string name, string color)
    {
        this.name = name;
        this.color = color;
    }

    /// <summary>
    /// 猫进屋(猫的状态发生改变)或者(被观察者的状态发生改变)
    /// </summary>
    public void CatComing()
    {
        Debug.LogError(color + "的叫" + name + "的猫过来了");
        if (catComedlg != null)
        {
            catComedlg(); //触发消息
        }
    }

    // 定义一个委托，通过委托发布消息
    public delegate void CatComedlg();
}
