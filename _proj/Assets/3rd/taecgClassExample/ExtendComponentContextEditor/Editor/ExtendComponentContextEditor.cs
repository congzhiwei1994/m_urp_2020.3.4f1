using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ExtendComponentContextEditor : Editor
{
    #region[随机旋转]
    [MenuItem("CONTEXT/Transform/随机旋转")]
    private static void RandomRotation(MenuCommand cmd)
    {
        // 获取需要扩展的对象
        Transform trans = (Transform)cmd.context;
        trans.rotation = Random.rotation;
    }

    [MenuItem("CONTEXT/Transform/随机旋转", true, 0)]
    private static bool OnRandomRotationValidate(MenuCommand cmd)
    {
        var trans = (Transform)cmd.context;
        return trans.eulerAngles == Vector3.zero;
    }
    #endregion

    #region [其它类的上下文拓展]
    [MenuItem("CONTEXT/BoxCollider/测试")]
    private static void ExtendBoxClider(MenuCommand cmd)
    {
        BoxCollider bc = (BoxCollider)cmd.context;
    }
    #endregion

    #region [自定义类的上下文拓展]
    [MenuItem("CONTEXT/ExtendComponentContext/测试自定义类")]
    private static void CustormClass(MenuCommand Cmd)
    {

    }
    #endregion
}
