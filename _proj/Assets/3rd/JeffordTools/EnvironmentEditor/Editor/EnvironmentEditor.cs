using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.SceneManagement;

namespace Jefford.EnvironmentEditor
{
    public class EnvironmentEditor : EditorWindow
    {
        private static string m_currentScenePath;
        private EnvironmentStatus m_status;



        [MenuItem("Jefford/EnvironmentEditor")]
        private static void Open()
        {
            var window = GetWindow<EnvironmentEditor>("环境编辑器");
            window.Show();

            m_currentScenePath = SceneManager.GetActiveScene().path;
        }

        private void OnEnable()
        {
            InitWindow();
        }

        private void InitWindow()
        {
            InitView();
        }
        private void InitView()
        {

        }

        private void InitStatus()
        {
            m_status = new EnvironmentStatus();
        }
    }
}

