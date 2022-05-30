using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Jefford
{
    public class TestRTRenderPass : ScriptableRenderPass
    {
        private TestRTRenderFeature.TestRT m_setting;
        private RenderTargetHandle m_renderTargetHandle;
        private RenderTargetIdentifier m_sourceID;
        private ScriptableRenderer m_renderer;
        private Material m_DrawMeshMaterial;


        public TestRTRenderPass()
        {
            m_renderTargetHandle.Init("_TestRTRenderFeature");
        }

        public void Setup(RenderTargetIdentifier sourceID, TestRTRenderFeature.TestRT setting, ScriptableRenderer renderer)
        {
            this.m_sourceID = sourceID;
            this.m_setting = setting;
            this.m_renderer = renderer;
            this.m_DrawMeshMaterial = setting.m_DrawMeshMaterial;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {

        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            // 拿到当前的相机
            var camera = renderingData.cameraData.camera;

            // 筛选渲染相机
            if (camera.cameraType != CameraType.Game || renderingData.cameraData.renderType != CameraRenderType.Base)
                return;
            if (m_DrawMeshMaterial == null)
            {
                Debug.LogError("m_DrawMeshMaterial Is Null");
                return;
            }

            // 获取当前相机RT的描述
            var cameraTargetDes = renderingData.cameraData.cameraTargetDescriptor;
            // 将获取的RT进行降采样
            var downSamplecameraTargetDes = new RenderTextureDescriptor(cameraTargetDes.width / m_setting.m_DownSample, cameraTargetDes.height / m_setting.m_DownSample);
            //    将其深度设置为0
            downSamplecameraTargetDes.depthBufferBits = 0;
            // 在池中获取一个Command Buffer
            var cmd = CommandBufferPool.Get("TestRT");

            // 按照获取当前相机RT的描述设置来获取的RT
            cmd.GetTemporaryRT(m_renderTargetHandle.id, downSamplecameraTargetDes);
            // 将 m_sourceID Blit到 m_renderTargetHandle
            cmd.Blit(m_sourceID, m_renderTargetHandle.Identifier());
            // 将 m_renderTargetHandle设置为全局变量
            cmd.SetGlobalTexture("_TestRTRenderFeature", m_renderTargetHandle.Identifier());

            // 将RT设置回原来的RenderTarget
            cmd.SetRenderTarget(m_sourceID, m_renderer.cameraDepthTarget);

            DrawMesh(cmd, renderingData.cameraData);
            // 执行
            context.ExecuteCommandBuffer(cmd);
            // 将创建的 CommandBuffer Release掉
            CommandBufferPool.Release(cmd);
        }
        //  绘制Mesh
        private void DrawMesh(CommandBuffer cmd, CameraData cameraData)
        {
            // 设置视空间矩阵和投影矩阵
            cmd.SetViewProjectionMatrices(Matrix4x4.identity, Matrix4x4.identity);
            // 绘制全屏Mesh
            cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, m_DrawMeshMaterial, 0, 0);

            // 绘制玩完Mesh之后必须设置回之前的视空间矩阵和投影矩阵
            cmd.SetViewProjectionMatrices(cameraData.GetViewMatrix(), cameraData.GetProjectionMatrix());
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            // 用完释放
            cmd.ReleaseTemporaryRT(m_renderTargetHandle.id);
        }
    }

}
