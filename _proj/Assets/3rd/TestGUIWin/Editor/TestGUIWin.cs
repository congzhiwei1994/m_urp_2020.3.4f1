using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class TestGUIWin : EditorWindow
{
    [MenuItem("Jefford/TestGUIWin")]
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
        EditorGUILayout.LabelField("LabelField");
        EditorGUILayout.TextField("TextField");
        EditorGUILayout.TagField("TagField");
        EditorGUILayout.ToggleGroupScope ToggleGroupScope = new EditorGUILayout.ToggleGroupScope("ToggleGroupScope", true);
        EditorGUILayout.ToggleLeft("ToggleLeft", true);
        EditorGUILayout.Vector2Field("Vector2Field", Vector2.one);
        EditorGUILayout.Vector3Field("Vector3Field", Vector3.zero);
        EditorGUILayout.BoundsField("BoundsField", new Bounds());
        EditorGUILayout.ColorField("ColorField", Color.blue);
        EditorGUILayout.CurveField("CurveField", new AnimationCurve());
        EditorGUILayout.DelayedDoubleField("DelayedDoubleField", double.MaxValue);
        EditorGUILayout.EnumFlagsField("EnumFlagsField", UnityEngine.RenderMode.ScreenSpaceCamera);
        EditorGUILayout.EnumPopup("EnumPopup", UnityEngine.RenderMode.ScreenSpaceCamera);

    }
}
