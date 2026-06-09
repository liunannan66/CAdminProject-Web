<script setup lang="ts">
import { computed } from 'vue';
import { useAppStore } from '@/store/modules/app';
import { $t } from '@/locales';
import pkg from '~/package.json';

defineOptions({ name: 'AboutPage' });

const appStore = useAppStore();

const column = computed(() => (appStore.isMobile ? 1 : 2));

interface PkgJson {
  name: string;
  version: string;
  dependencies: PkgVersionInfo[];
  devDependencies: PkgVersionInfo[];
}

interface PkgVersionInfo {
  name: string;
  version: string;
}

const { name, version, dependencies, devDependencies } = pkg;

function transformVersionData(tuple: [string, string]): PkgVersionInfo {
  const [$name, $version] = tuple;
  return {
    name: $name,
    version: $version
  };
}

const pkgJson: PkgJson = {
  name,
  version,
  dependencies: Object.entries(dependencies).map(item => transformVersionData(item)),
  devDependencies: Object.entries(devDependencies).map(item => transformVersionData(item))
};

const latestBuildTime = BUILD_TIME;
</script>

<template>
  <ElSpace direction="vertical" fill :size="16">
    <ElCard :header="$t('page.about.title')" size="small" segmented class="card-wrapper">
      <ElDescriptions label-placement="left" border :column="column">123123123123</ElDescriptions>
      <div>
        <P>后台管理系统</P>
        <br />
        <P>
          基于NET Core | NET7/8 & Sqlsugar | Vue3 | vite4 | TypeScript | Element-plus
          开发的前后端分离式权限管理系统,采用最原生最简洁的方式来实现, 前端清新优雅高颜值，后端
          结构清晰，优雅易懂，功能强大,提供快速开发的解决方案。
        </P>
        <br />
        <P>后端：基于 .NET7 和 sqlsugar ，集成常用组件，从0到1搭建。</P>
        <br />
        <P>前端：基于 Soybean Admin 做适配，主技术栈：Vue3、NaiveUI 版本</P>
        <br />
      </div>
      <div style="display: none;">
        <ul>
          <li>
            公众号: （持续分享编程干货和有趣的知识）
            <a
              href="https://mp.weixin.qq.com/s/7zwCvOroFsBwKNmmZR17RA"
              class="text-primary"
              target="_blank"
              rel="noopener noreferrer"
            >
              Netshare
            </a>
          </li>
        </ul>
        <br />
      </div>
    </ElCard>
    <ElCard :header="$t('page.about.projectInfo.title')" size="small" class="card-wrapper">
      项目信息
    </ElCard>
  </ElSpace>
</template>

<style scoped></style>
