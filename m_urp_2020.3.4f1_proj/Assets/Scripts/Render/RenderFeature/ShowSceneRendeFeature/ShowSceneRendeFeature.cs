using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections;
using System.Collections.Generic;

public class ShowSceneRendeFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class ShowSceneRenderSetting
    {
        public RenderPassEvent m_renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
        public Material m_material;
        public Material m_UImaterial;
        public float offset = 0;
        public float offset_Y = 0;

        public List<Vector3> list = new List<Vector3>() { new Vector3(-1, -1, 0), new Vector3(-1, 1, 0), new Vector3(1, -1, 0), new Vector3(1, 1, 0) };
    }

    ShowSceneRendePass m_ScriptablePass;
    public ShowSceneRenderSetting setting = new ShowSceneRenderSetting();
    public override void Create()
    {

        if (setting.m_material == null || setting.m_UImaterial == null)
        {
            return;
        }

        if (setting.list.Count != 4)
        {
            return;
        }

        m_ScriptablePass = new ShowSceneRendePass(setting);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


