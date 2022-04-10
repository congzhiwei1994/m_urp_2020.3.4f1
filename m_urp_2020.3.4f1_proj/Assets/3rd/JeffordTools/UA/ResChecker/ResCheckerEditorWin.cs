using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

namespace UA.ResChecker
{
    public class ResCheckerEditorWin : EditorWindow
    {
        // 当前检测的资源
        HashSet<CheckerType> m_checkerType = new HashSet<CheckerType>();
        public enum CheckerType
        {
            材质配置,
            预制体,
            Shader
        }

        public Dictionary<CheckerType, ResCheckerFolder> GetAllCheckConfig()
        {
            var dic = new Dictionary<CheckerType, ResCheckerFolder>();
            dic.Add(CheckerType.材质配置, new ResCheckerTypePrefab());
            dic.Add(CheckerType.Shader, new ResCheckerTypeShader());
            return dic;
        }

        public List<string> CheckRes(bool isRepair, Func<CheckerType, bool> filter)
        {
            // 创建检测类型列表
            var _list = new List<CheckerType>();
            var _allConfigDic = GetAllCheckConfig();

            foreach (var config in _allConfigDic)
            {
                if (filter != null || !filter(config.Key))
                {
                    continue;
                }
                // filter = null || filter(config.Key) = true
                _list.Add(config.Key);
            }
            _list.Sort();

            // 检测配置
            var _defaultConfig = CreatDefaultCheckerConfig();
            foreach (var item in _list)
            {
                _defaultConfig.AddCheckerFolder(_allConfigDic[item]);
            }
            CreatDefaultCheckerConfig();
            return null;

        }

        //  默认检测配置
        public ResCheckerConfig CreatDefaultCheckerConfig()
        {
            ResCheckerConfig config = new ResCheckerConfig();
            config.m_checkIsExport = (string path) =>
            {
                return path.Contains("/不导出/");
            };

            config.m_checkIsPublic = (string path) =>
            {
                return path.Contains("/3rd/");
            };

            return config;
        }

        [MenuItem("Jefford/资源检测")]
        private static void Open()
        {
            var win = GetWindow<ResCheckerEditorWin>("资源检测");
            win.Show();
        }

        private void OnGUI()
        {
            var allCheckConfigDic = GetAllCheckConfig();
            foreach (var dic in allCheckConfigDic)
            {
                var on = m_checkerType.Contains(dic.Key);
                var newOn = EditorGUILayout.Toggle(dic.Key.ToString(), on);
                if (on != newOn)
                {
                    if (newOn)
                    {
                        m_checkerType.Add(dic.Key);
                    }

                    else
                    {
                        m_checkerType.Remove(dic.Key);
                    }
                }
            }

            if (GUILayout.Button("检测"))
            {
                CheckRes(false, type =>
                {
                    return m_checkerType.Contains(type);
                });
            }
        }
    }
}

