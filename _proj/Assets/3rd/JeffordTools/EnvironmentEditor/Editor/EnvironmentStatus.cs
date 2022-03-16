using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using Scene = UnityEngine.SceneManagement.Scene;
// using System;

namespace Jefford.EnvironmentEditor
{
    public class EnvironmentStatus
    {
        public Environment m_environment;
        public void Init()
        {
            InitEnvCamera();
        }

        public void InitEnvCamera()
        {
            if (Application.isPlaying)
            {
                if (m_environment.m_envCamera != null)
                {
                    m_environment.m_envCamera.enabled = false;
                }
            }

            if (m_environment.m_envCamera != null)
            {
                return;
            }
            var envCamera = GameObject.Find("BakeCamera");
            if (envCamera == null)
            {
                envCamera = new GameObject("BakeCamera");
                envCamera.transform.parent = m_environment.transform;
                var camera = envCamera.AddComponent<Camera>();
                m_environment.m_envCamera = camera;

            }
            else
            {
                var camera = envCamera.GetComponent<Camera>();
                m_environment.m_envCamera = camera;
            }
        }
    }
}

