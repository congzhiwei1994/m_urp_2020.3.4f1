using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 观察者类 ： 老鼠
public class Mouse
{
    private string name;
    private string color;

    private Cat _cat;

    public Mouse(string name, string color)
    {
        this.name = name;
        this.color = color;
    }

    /// <summary>
    /// 逃跑功能
    /// </summary>
    public void RunAway()
    {
        Debug.LogError(color + "的老鼠" + name + "说: 老猫了!赶紧跑.........");
    }

    public void Watch(Cat cat)
    {
        _cat = cat;
        cat.catComedlg += RunAway;
    }

    public void CancelWatch(Cat cat)
    {
        if (_cat != null)
        {
            _cat.catComedlg -= RunAway;
            _cat = null;
        }

    }

}
