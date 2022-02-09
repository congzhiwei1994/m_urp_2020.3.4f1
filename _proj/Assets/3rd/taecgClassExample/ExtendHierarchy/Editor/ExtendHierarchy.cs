using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ExtendHierarchy
{
    // 优先级小于50即可显示
    [MenuItem("GameObject/Test", false, 0)]
    private static void Test()
    {

    }

    [MenuItem("GameObject/Select/选择主相机", priority = 1)]
    private static void SelectedMainCamera()
    {
        if (Camera.main != null)
        {
            Selection.activeObject = Camera.main;
        }
        else
        {
            return;
        }
    }

    [MenuItem("GameObject/Select/选择主灯")]
    private static void SelectMainLight()
    {
        var light01 = GameObject.Find("Directional Light");
        if (light01)
        {
            Selection.activeObject = light01;
            return;
        }

        var light02 = GameObject.FindObjectOfType<Light>();
        if (light02 && light02.type == LightType.Directional)
        {
            Selection.activeObject = light02;
            return;
        }

        Debug.LogError("场景没有灯光");
        return;
    }

    // 当unity加载的时候会初始化加载下面的方法
    [InitializeOnLoadMethod]
    static void ShowTransCount()
    {
        EditorApplication.hierarchyWindowItemOnGUI = (int instanceID, Rect selectionRect) =>
       {
           var go = (GameObject)EditorUtility.InstanceIDToObject(instanceID);
           if (go)
           {
               GUIStyle style = new GUIStyle("lable");
               style.alignment = TextAnchor.MiddleRight;
               var count = go.GetComponentsInChildren<Transform>().Length - 1;
               if (count > 0)
               {
                   var colorTemp = GUI.color;
                   GUI.color = Color.black;
                   if (count > 3)
                   {
                       GUI.color = Color.red;
                   }
                   GUI.Label(selectionRect, count.ToString(), style);
                   GUI.color = colorTemp;
               }
           }
       };
    }
}
