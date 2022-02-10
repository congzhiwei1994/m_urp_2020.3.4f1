using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ExtendProjectEditor
{
    [MenuItem("Assets/Test..")]
    static void ExtendProjectTest()
    {
        Debug.LogError("Project");
    }

    // unity加载时调用此特性下面的方法
    [InitializeOnLoadMethod]
    private static void InitProject()
    {
        EditorApplication.projectWindowItemOnGUI = (string guid, Rect selectionRect) =>
        {
            // Debug.LogError(2);
        };

    }
}
