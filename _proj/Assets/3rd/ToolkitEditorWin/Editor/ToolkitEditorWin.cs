using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ArtToolEditorWin : EditorWindow
{
    [MenuItem("TA/工具集")]
    private static void Window()
    {
        var win = GetWindow<ArtToolEditorWin>("工具集");
        win.Show();
    }
}
