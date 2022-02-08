using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExtendComponentContext : MonoBehaviour
{
    // [ContextMenu("测试自定义类上下文菜单")]
    // private void ContextFunction()
    // {
    //     Debug.LogError(name);
    // }

    [ContextMenuItem("字段上的上下文菜单", "ContextFunction")]
    public string Name;
    [ContextMenu("测试自定义类上下文菜单")]
    private void ContextFunction()
    {
        Debug.LogError(name);
    }
}
