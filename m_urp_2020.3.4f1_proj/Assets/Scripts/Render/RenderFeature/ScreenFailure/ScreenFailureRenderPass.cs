// using System.Collections;
// using System.Collections.Generic;
// using UnityEngine;
// using UnityEngine.Experimental.Rendering.Universal;
// using UnityEngine.Rendering;
// using UnityEngine.Rendering.Universal;
//
// public class ScreenFailureRenderPass : ScriptableRenderPass
// {
//     private RenderTargetHandle _renderTargetHandle;
//     private RenderTargetIdentifier source;
//     private ScriptableRenderer _renderer;
//
//     private Material _material;
//     
//     public ScreenFailureRenderPass(ScreenFailureRenderFeature.ScreenFailureSetting setting)
//     {
//         this._material = setting.material;
//
//         _renderTargetHandle.Init("_ScreenFailure");
//     }
//
//     public void Setup(RenderTargetIdentifier source, ScriptableRenderer renderer)
//     {
//         this.source = source;
//         this._renderer = renderer;
//     }
//
//     public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
//     {
//
//     }
//
//
//     public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
//     {
//         if (_material == null )
//         {
//             return;
//         }
//         
//         if (renderingData.cameraData.cameraType == CameraType.SceneView)
//         {
//             return;
//         }
//
//         var sourceDes = renderingData.cameraData.cameraTargetDescriptor;
//
//         var cmd = CommandBufferPool.Get();
//         cmd.GetTemporaryRT(_renderTargetHandle.id, sourceDes);
//         cmd.Blit(source, _renderTargetHandle.Identifier());
//         cmd.SetGlobalTexture("_ScreenFailure", _renderTargetHandle.Identifier());
//         cmd.SetRenderTarget(source, _renderer.cameraDepthTarget);
//
//         cmd.SetViewProjectionMatrices(Matrix4x4.identity, Matrix4x4.identity);
//         cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, _material);
//         cmd.SetViewProjectionMatrices(renderingData.cameraData.GetViewMatrix(),
//             renderingData.cameraData.GetProjectionMatrix());
//
//         context.ExecuteCommandBuffer(cmd);
//         CommandBufferPool.Release(cmd);
//     }
//
//     public override void OnCameraCleanup(CommandBuffer cmd)
//     {
//         cmd.ReleaseTemporaryRT(_renderTargetHandle.id);
//     }
// }
//
