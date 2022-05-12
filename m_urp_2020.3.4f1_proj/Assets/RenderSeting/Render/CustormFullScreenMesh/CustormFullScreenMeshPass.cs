using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


class CustormFullScreenMeshPass : ScriptableRenderPass
{

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
    }


    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
    }


    public override void OnCameraCleanup(CommandBuffer cmd)
    {
    }
}




