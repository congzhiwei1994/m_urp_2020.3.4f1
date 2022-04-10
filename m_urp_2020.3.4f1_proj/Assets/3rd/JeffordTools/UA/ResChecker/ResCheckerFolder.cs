using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using UA.ResHelper;

namespace UA.ResChecker
{
    public class ResCheckerFolder
    {
        public string m_folder;

        // 筛选类型
        public Func<string, bool> m_filter;

        public bool m_isIncludeExporter = false;

        //获得资源路径
        public string GetAssetFolder()
        {
            string folder = m_folder.Replace(@"\", "/");
            string folder2 = UA.ResHelper.ResHelper.M_ResPath + folder;
            if (!folder2.EndsWith("/"))
            {
                folder2 += "/";
            }
            return folder2;
        }

        public void AddCheckerFolder()
        {

        }

    }
}

