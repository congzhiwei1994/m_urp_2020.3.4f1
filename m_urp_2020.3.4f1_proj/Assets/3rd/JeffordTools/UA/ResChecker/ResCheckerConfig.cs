using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;



namespace UA.ResChecker
{
    public class ResCheckerConfig
    {
        /// <summary>
        ///  通过路径来判断资源是否需要导出
        /// </summary>
        public Func<String, bool> m_checkIsExport = null;
        // 判断资源是否是公共资源
        public Func<String, bool> m_checkIsPublic = null;
        public List<ResCheckerFolder> m_resCheckerFolderList = new List<ResCheckerFolder>();
        public void AddCheckerFolder(ResCheckerFolder checkFolder)
        {
            m_resCheckerFolderList.Add(checkFolder);
        }
    }
}
