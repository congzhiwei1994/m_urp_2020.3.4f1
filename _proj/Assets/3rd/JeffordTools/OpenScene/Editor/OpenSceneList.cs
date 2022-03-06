using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEditor;

namespace Jefford.OpenScene
{
    [CreateAssetMenu(menuName = "Jefford/CreatOpenSceneAsset", fileName = "SceneAsset")]
    [Serializable]
    public class OpenSceneList : ScriptableObject
    {
        [SerializeField]
        public List<SceneAsset> assetList = new List<SceneAsset>();

        public static OpenSceneList Load()
        {
            var guids = AssetDatabase.FindAssets("t:OpenSceneList", new string[] { "Assets/3rd/JeffordTools/OpenScene/Editor" });
            if (guids.Length == 0)
            {
                var _sceneAsset = ScriptableObject.CreateInstance<OpenSceneList>();
                return _sceneAsset;
            }
            else
            {
                var _path = AssetDatabase.GUIDToAssetPath(guids[0]);
                var _sceneAsset = AssetDatabase.LoadAssetAtPath<OpenSceneList>(_path);
                return _sceneAsset;
            }
        }
    }

}
