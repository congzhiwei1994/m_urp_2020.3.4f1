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
        private int m_CurrPickerSceneControlID;
        private List<GameObject> characterList = new List<GameObject>();
        private Dictionary<string, string> m_CharacterDic = new Dictionary<string, string>();

        private string m_SearchCharacter = "Name";

        private const string m_characterPath = "Assets/Res/Example";

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
            LoadCharacterAssets();
        }

        private void OnGUI()
        {

            DrawOpenSceneGUI();
            HandleSceneAssetPickEvent();
            DrawCharacterGUI();
        }

        private void OnDisable()
        {
            if (m_CharacterDic.Count != 0)
            {
                m_CharacterDic.Clear();
            }
            m_SearchCharacter = "Name";
        }

        private void DrawOpenSceneGUI()
        {
            EditorGUILayout.BeginScrollView(m_scrollViewPos, EditorStyles.helpBox, GUILayout.Height(200));
            {
                EditorGUILayout.TextField("Search", "");

                for (var i = 0; i < m_SceneDic.Count; i++)
                {
                    var element = m_SceneDic.ElementAt(i);

                    EditorGUILayout.BeginHorizontal();
                    {
                        EditorGUILayout.LabelField(element.Key);
                        GUILayout.FlexibleSpace();
                        if (GUILayout.Button("Open", GUILayout.Width(50)))
                        {
                            EditorSceneManager.OpenScene(element.Value);
                        }

                        if (GUILayout.Button("Ping", GUILayout.Width(50)))
                        {
                            var scene = AssetDatabase.LoadAssetAtPath(element.Value, typeof(SceneAsset));
                            EditorGUIUtility.PingObject(scene);
                        }

                        if (GUILayout.Button("Remove", GUILayout.Width(70)))
                        {
                            m_SceneDic.Remove(element.Key);
                            sceneAssetList.assetList.Remove(AssetDatabase.LoadAssetAtPath<SceneAsset>(element.Value));
                        }
                    }
                    EditorGUILayout.EndHorizontal();
                }

                EditorGUILayout.BeginHorizontal();
                {
                    if (GUILayout.Button(new GUIContent("*", "刷新"), GUILayout.Width(25)))
                    {
                        Init();
                    }

                    if (GUILayout.Button(new GUIContent("+", "添加"), GUILayout.Width(25)))
                    {
                        m_CurrPickerSceneControlID = EditorGUIUtility.GetControlID(FocusType.Passive) + 10;
                        EditorGUIUtility.ShowObjectPicker<SceneAsset>(null, true, "", m_CurrPickerSceneControlID);
                    }

                }
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndScrollView();
        }

        private void HandleSceneAssetPickEvent()
        {
            var commandName = Event.current.commandName;
            if (commandName == "ObjectSelectorUpdated")
            {
                Repaint();
            }

            if (commandName != "ObjectSelectorClosed" && EditorGUIUtility.GetObjectPickerControlID() != m_CurrPickerSceneControlID)
            {
                return;
            }

            m_CurrPickerSceneControlID = -1;

            var sceneAsset = (SceneAsset)EditorGUIUtility.GetObjectPickerObject();
            if (sceneAsset == null)
            {
                return;
            }

            m_SceneDic.Add(sceneAsset.name, AssetDatabase.GetAssetPath(sceneAsset));
            sceneAssetList.assetList.Add(sceneAsset);
            EditorUtility.SetDirty(sceneAssetList);
        }
        private void DrawCharacterGUI()
        {
            EditorGUILayout.BeginScrollView(m_scrollViewPos, EditorStyles.helpBox, GUILayout.Height(200));
            {
                EditorGUILayout.LabelField("添加角色");
                m_SearchCharacter = EditorGUILayout.TextField("Search", m_SearchCharacter).ToLower();

                foreach (var item in m_CharacterDic)
                {
                    if (item.Key.ToLower().Contains(m_SearchCharacter))
                    {
                        Debug.LogError(item.Key);
                        EditorGUILayout.BeginHorizontal();
                        {
                            EditorGUILayout.LabelField(item.Key);
                            if (GUILayout.Button("Add", GUILayout.Width(50)))
                            {
                                var go = AssetDatabase.LoadAssetAtPath(item.Value, typeof(GameObject));
                                Selection.activeObject = PrefabUtility.InstantiatePrefab(go);
                            }
                        }
                        EditorGUILayout.EndHorizontal();
                    }
                }
            }
            EditorGUILayout.EndScrollView();
        }

        private void LoadCharacterAssets()
        {
            m_CharacterDic.Clear();
            var guids = AssetDatabase.FindAssets("t:prefab", new string[] { m_characterPath });
            foreach (var guid in guids)
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                var go = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                m_CharacterDic.Add(go.name, AssetDatabase.GetAssetPath(go));
            }
        }
    }
}

