using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustormFullScreenMeshFeature : ScriptableRendererFeature
{
    CustormFullScreenMeshPass m_ScriptablePass;
    public override void Create()
    {
        m_ScriptablePass = new CustormFullScreenMeshPass();
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


