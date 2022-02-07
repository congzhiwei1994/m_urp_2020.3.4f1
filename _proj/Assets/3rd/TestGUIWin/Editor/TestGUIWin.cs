using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class TestGUIWin : EditorWindow
{
    [MenuItem("TA/TestGUIWin &D")]
    private static void Window()
    {
        var win = GetWindow<TestGUIWin>("TestGUIWin");
        win.Show();
    }
    private void OnGUI()
    {
        DrawGUI();
    }

    private void DrawGUI()
    {
        if (GUILayout.Button("Test"))
        {
            var go = Selection.activeGameObject;
            // 记录上一步的状态
            Undo.RecordObject(go, "Cube");
            // 进行更改命名
            go.name = "xxx";
            // 开关游戏对象
            // go.SetActive(!go.activeSelf);

            StaticEditorFlags flags = StaticEditorFlags.ContributeGI | StaticEditorFlags.OccludeeStatic;
            GameObjectUtility.SetStaticEditorFlags(go, flags);
            go.tag = "EditorOnly";
            Debug.LogError(go);
        }
    }
}
