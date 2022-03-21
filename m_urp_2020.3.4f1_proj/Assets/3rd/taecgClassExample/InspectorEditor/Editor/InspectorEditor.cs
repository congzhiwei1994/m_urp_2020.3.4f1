using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

// [CustomEditor(typeof(Transform))]
public class InspectorEditor : Editor
{
    private Transform trans;
    private void OnEnable()
    {
        trans = (Transform)target;
    }
    public override void OnInspectorGUI()
    {
        // EditorGUILayout.BeginHorizontal();
        // {
        //     trans.position = EditorGUILayout.Vector3Field("Position", trans.position);
        //     if (GUILayout.Button("R", GUILayout.Width(20)))
        //     {
        //         trans.position = Vector3.zero;
        //     }
        // }
        // EditorGUILayout.EndHorizontal();


        base.OnInspectorGUI();
    }
}
