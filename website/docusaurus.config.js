// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'EKS Upgrades Workshop',
  tagline: 'Dinosaurs are cool',
  favicon: 'img/favicon.png',

  // Set the production url of your site here
  url: 'https://your-docusaurus-test-site.com',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'aws-samples', // Usually your GitHub org/user name.
  projectName: 'eks-upgrades-workshop', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        defaultMode: 'dark',
        disableSwitch: true
      },
      // Replace with your project's social card
      image: 'img/meta.png',
      navbar: {
        title: 'EKS Upgrades Workshop',
        logo: {
          alt: 'AWS Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'doc',
            docId: 'create-the-environment/select-your-environment',
            position: 'left',
            label: 'Setup',
          },
          {
            type: 'doc',
            docId: 'explore-environment/why-gitops',
            position: 'left',
            label: 'Exploring environment',
          },
          {
            type: 'doc',
            docId: 'gitops-reconciliation/gitops-reconciliation',
            position: 'left',
            label: 'GitOps',
          },
          {
            type: 'doc',
            docId: 'karpenter-scaling/karpenter-scaling',
            position: 'left',
            label: 'Karpenter Scaling',
          },
          {
            type: 'doc',
            docId: 'validating-state/validating-state',
            position: 'left',
            label: 'Validating State',
          },
          {
            type: 'doc',
            docId: 'eks-control-plane-upgrade/eks-upgrade',
            position: 'left',
            label: 'Control Plane',
          },
          {
            type: 'doc',
            docId: 'managed-nodes-upgrade/managed-nodes-upgrade',
            position: 'left',
            label: 'Managed Nodes',
          },
          {
            type: 'doc',
            docId: 'upgrade-managed-addons/managed-addons-upgrade',
            position: 'left',
            label: 'Managed Add-ons',
          },
          {
            type: 'doc',
            docId: 'rollout-nodes-with-karpenter/rollout-nodes',
            position: 'left',
            label: 'Rollout Application Nodes',
          },
          {
            href: 'https://github.com/lusoal/eks-cluster-upgrades-reference-arch',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          // {
          //   title: 'Docs',
          //   items: [
          //     {
          //       label: 'Tutorial',
          //       to: '/docs/intro',
          //     },
          //   ],
          // },
          // {
          //   title: 'Community',
          //   items: [
          //     {
          //       label: 'Stack Overflow',
          //       href: 'https://stackoverflow.com/questions/tagged/docusaurus',
          //     },
          //     {
          //       label: 'Discord',
          //       href: 'https://discordapp.com/invite/docusaurus',
          //     },
          //     {
          //       label: 'Twitter',
          //       href: 'https://twitter.com/docusaurus',
          //     },
          //   ],
          // },
          // {
          //   title: 'More',
          //   items: [
          //     {
          //       label: 'Blog',
          //       to: '/blog',
          //     },
          //     {
          //       label: 'GitHub',
          //       href: 'https://github.com/facebook/docusaurus',
          //     },
          //   ],
          // },
        ],
        copyright: `© ${new Date().getFullYear()} Amazon Web Services, Inc. or its affiliates. All rights reserved.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
    }),
};

module.exports = config;
