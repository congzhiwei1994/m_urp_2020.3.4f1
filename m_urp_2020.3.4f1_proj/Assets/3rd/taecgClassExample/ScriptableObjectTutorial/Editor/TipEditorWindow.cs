using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


public class TipEditorWindow : EditorWindow
{
    private ScriptableObjectTutorial asset;
    private SerializedObject so;
    private Vector2 pos = Vector2.zero;
    [MenuItem("TA/Tip")]
    static void Open()
    {
        var win = GetWindow<TipEditorWindow>();
        win.titleContent = new GUIContent("Tips......");
        win.Show();
    }

    void OnEnable()
    {
        asset = (ScriptableObjectTutorial)AssetDatabase.LoadAssetAtPath("Assets/3rd/taecgClassExample/ScriptableObjectTutorial/new TipAsset.asset", typeof(ScriptableObjectTutorial));
        so = new SerializedObject(asset);
    }

    void OnGUI()
    {
        pos = EditorGUILayout.BeginScrollView(pos);
        so.Update(); // 更新
        EditorGUILayout.PropertyField(so.FindProperty("tipsText"), new GUIContent("Tips"));
        so.ApplyModifiedProperties(); // 应用修改
        EditorGUILayout.EndScrollView();
    }

}
