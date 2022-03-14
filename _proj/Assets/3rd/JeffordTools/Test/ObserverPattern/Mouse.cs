using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 观察者类 ： 老鼠
public class Mouse
{
    private string name;
    private string color;

    public Mouse(string name, string color, Cat cat)
    {
        this.name = name;
        this.color = color;
        cat.catComedlg += RunAway; // 订阅消息 把自身逃跑方法注册进猫里面
    }

    /// <summary>
    /// 逃跑功能
    /// </summary>
    public void RunAway()
    {
        Debug.LogError(color + "的老鼠" + name + "说: 老猫了!赶紧跑.........");
    }

}
