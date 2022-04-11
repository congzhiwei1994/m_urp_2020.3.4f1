using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

namespace UA.ResChecker
{
    public class ResCheckerTypePrefab : ResCheckerFolder
    {
        public ResCheckerTypePrefab()
        {
            m_folder = "";
            m_filter = (string path) =>
            {
                Debug.LogError(path);
                return path.EndsWith("prefab");
            };
            m_isIncludeExporter = true;
        }
    }
}

