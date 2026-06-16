<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { ElMessage } from 'element-plus';
import WangEditor from 'wangeditor';
import type { FileBizType } from '@/constants/file';
import { resolveStaticFileUrl, uploadFile } from '@/service/api/file';

defineOptions({ name: 'RichTextEditor' });

const props = withDefaults(
  defineProps<{
    placeholder?: string;
    height?: number;
    /** 图片上传业务类型，默认富文本专用 richtext */
    uploadBizType?: FileBizType;
  }>(),
  {
    placeholder: '请输入内容',
    height: 360,
    uploadBizType: 'richtext'
  }
);

const model = defineModel<string>({ default: '' });

const editorRef = ref<WangEditor>();
const domRef = ref<HTMLElement>();
const isSettingContent = ref(false);

const IMAGE_ACCEPT = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp']);
const IMAGE_MAX_SIZE = 5 * 1024 * 1024;

function getFileExtension(file: File) {
  const name = file.name || '';
  const index = name.lastIndexOf('.');
  return index >= 0 ? name.slice(index + 1).toLowerCase() : '';
}

async function uploadLocalImage(file: File) {
  const ext = getFileExtension(file);
  if (!IMAGE_ACCEPT.has(ext)) {
    throw new Error('仅支持 jpg、png、gif、webp、bmp 图片');
  }
  if (file.size > IMAGE_MAX_SIZE) {
    throw new Error('图片大小不能超过 5MB');
  }

  const result = await uploadFile(file, props.uploadBizType);
  if (!result?.storedPath) {
    throw new Error('上传成功但未返回文件路径');
  }
  return resolveStaticFileUrl(result.storedPath);
}

function setupImageUpload(editor: WangEditor) {
  editor.config.uploadImgMaxSize = IMAGE_MAX_SIZE;
  editor.config.uploadImgAccept = [...IMAGE_ACCEPT];
  editor.config.showLinkImg = false;
  editor.config.customUploadImg = async (resultFiles: File[], insertImgFn: (url: string) => void) => {
    for (const file of resultFiles) {
      try {
        const imgUrl = await uploadLocalImage(file);
        insertImgFn(imgUrl);
      } catch (error) {
        ElMessage.error(error instanceof Error ? error.message : '图片上传失败');
      }
    }
  };
}

onMounted(() => {
  if (!domRef.value) return;

  const editor = new WangEditor(domRef.value);
  editor.config.zIndex = 100;
  editor.config.placeholder = props.placeholder;
  editor.config.height = props.height;
  setupImageUpload(editor);
  editor.config.onchange = (html: string) => {
    if (isSettingContent.value) return;
    model.value = html;
  };
  editor.create();

  isSettingContent.value = true;
  editor.txt.html(model.value || '');
  isSettingContent.value = false;
  editorRef.value = editor;
});

watch(
  () => model.value,
  value => {
    if (!editorRef.value) return;
    const current = editorRef.value.txt.html();
    if (current === (value || '')) return;
    isSettingContent.value = true;
    editorRef.value.txt.html(value || '');
    isSettingContent.value = false;
  }
);

onBeforeUnmount(() => {
  editorRef.value?.destroy();
});
</script>

<template>
  <div ref="domRef" class="rich-text-editor bg-white dark:bg-dark"></div>
</template>

<style scoped>
:deep(.w-e-toolbar) {
  background: inherit !important;
  border-color: var(--el-border-color) !important;
}

:deep(.w-e-text-container) {
  background: inherit;
  border-color: var(--el-border-color) !important;
}
</style>
