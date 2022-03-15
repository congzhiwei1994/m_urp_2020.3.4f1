using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using Scene = UnityEngine.SceneManagement.Scene;

namespace Jefford.EnvironmentEditor
{
    public class EnvironmentEditor : EditorWindow
    {
        private const string EnvRootName = "Environment";
        private static string m_currentScenePath;
        private EnvironmentStatus m_status;



        [MenuItem("Jefford/EnvironmentEditor")]
        private static void Open()
        {
            var window = GetWindow<EnvironmentEditor>("环境编辑器");
            window.Show();

            m_currentScenePath = EditorSceneManager.GetActiveScene().path;

        }

        private void OnEnable()
        {
            InitWindow();
        }

        private void InitWindow()
        {
            InitView();
            InitStatus();
        }
        private void InitView()
        {

        }

        private void InitStatus()
        {
            m_status = new EnvironmentStatus();
            Scene activeScene = EditorSceneManager.GetActiveScene();
            var go = FindSceneObject(activeScene, EnvRootName);
            if (go == null)
            {
                go = new GameObject(EnvRootName);
            }
            var env = GetOrAddComponent<Environment>(go);

            m_status.Init();
        }

        private GameObject FindSceneObject(Scene scene, string name)
        {
            var rootGOs = scene.GetRootGameObjects();
            foreach (var go in rootGOs)
            {
                Debug.LogError(go.name);
                if (go.name == name)
                {
                    return go;
                }
            }
            return null;
        }

        private T GetOrAddComponent<T>(GameObject gameObject) where T : Component
        {
            T component = gameObject.GetComponent<T>();
            if (component == null)
            {
                component = gameObject.AddComponent<T>();
            }
            return component;
        }
    }
}

