using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.Linq;

namespace Jefford.OpenScene
{
    public class OpenSceneEditorWin : EditorWindow
    {
        private OpenSceneList sceneAssetList;
        private Dictionary<string, string> m_SceneDic = new Dictionary<string, string>();
        private Vector2 m_scrollViewPos = Vector2.zero;

        [MenuItem("Jefford/打开场景工具")]
        private static void Open()
        {
            var win = GetWindow<OpenSceneEditorWin>();
            win.Show();
        }

        private void OnEnable()
        {
            sceneAssetList = OpenSceneList.Load();
            Init();
        }

        private void Init()
        {
            m_SceneDic.Clear();

            for (var i = sceneAssetList.assetList.Count - 1; i >= 0; i--)
            {
                var asset = sceneAssetList.assetList[i];
                if (asset == null)
                {
                    sceneAssetList.assetList.RemoveAt(i);
                }
                else
                {
                    m_SceneDic.Add(asset.name, AssetDatabase.GetAssetPath(asset));

                }
            }
        }

        private void OnGUI()
        {
            DrawOpenSceneGUI();
        }

        private void DrawOpenSceneGUI()
        {
            EditorGUILayout.TextField("Search", "");

            for (var i = 0; i < m_SceneDic.Count; i++)
            {
                var element = m_SceneDic.ElementAt(i);

                EditorGUILayout.BeginHorizontal();
                {
                    EditorGUILayout.LabelField(element.Key);
                    GUILayout.FlexibleSpace();
                    if (GUILayout.Button("打开", GUILayout.Width(50)))
                    {
                        EditorSceneManager.OpenScene(element.Value);
                    }

                    if (GUILayout.Button("Ping", GUILayout.Width(50)))
                    {
                        var scene = AssetDatabase.LoadAssetAtPath(element.Value, typeof(SceneAsset));
                        EditorGUIUtility.PingObject(scene);
                    }

                    if (GUILayout.Button("移除", GUILayout.Width(50)))
                    {
                        m_SceneDic.Remove(element.Key);

                        sceneAssetList.assetList.Remove(AssetDatabase.LoadAssetAtPath<SceneAsset>(element.Value));
                    }

                }
                EditorGUILayout.EndHorizontal();
            }


            EditorGUILayout.BeginHorizontal();
            {
                if (GUILayout.Button(new GUIContent("◕", "刷新"), GUILayout.Width(25)))
                {
                    Init();
                }

                if (GUILayout.Button(new GUIContent("+", "添加"), GUILayout.Width(25)))
                {
                    var controlID = EditorGUIUtility.GetControlID(FocusType.Passive);
                    EditorGUIUtility.ShowObjectPicker<SceneAsset>(null, true, "", controlID);

                    var obj = (SceneAsset)EditorGUIUtility.GetObjectPickerObject();
                    Debug.LogError(obj.name);
                }

            }
            EditorGUILayout.BeginHorizontal();

        }

    }
}

