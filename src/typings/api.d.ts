/**
 * Namespace Api
 *
 * All backend api type
 */
declare namespace Api {
  namespace Common {
    /** common params of paginating */
    interface PaginatingCommonParams {
      /** current page number */
      pageNo: number;
      /** page size */
      pageSize: number;
      /** total count */
      totalPage: number;
      /** total rows */
      totalRows: number;
    }

    interface SearchParams {
      pageNo: number;
      pageSize: number;
      keywords: string;
    }

    /** common params of paginating query list data */
    interface PaginatingQueryRecord<T = any> extends PaginatingCommonParams {
      records: T[];
    }

    /**
     * enable status
     *
     * - "1": enabled
     * - "2": disabled
     */
    type EnableStatus = '1' | '2';

    /** common record */
    type CommonRecord<T = any> = {
      /** record id */
      id: number;
      /** record creator */
      createBy: string;
      /** record create time */
      createTime: string;
      /** record updater */
      updateBy: string;
      /** record update time */
      updateTime: string;
      /** record status */
      status: EnableStatus | null;
    } & T;
  }

  /**
   * namespace Auth
   *
   * backend api module: "auth"
   */
  namespace Auth {
    interface LoginToken {
      token: string;
      refreshToken: string;
      id: number;
      name: string;
    }

    interface UserInfo {
      userId: string;
      userName: string;
      roles: string[];
      buttons: string[];
    }
  }

  /**
   * namespace Route
   *
   * backend api module: "route"
   */
  namespace Route {
    type ElegantConstRoute = import('@elegant-router/types').ElegantConstRoute;

    interface MenuRoute extends ElegantConstRoute {
      id: string;
    }

    interface UserRoute {
      routes: MenuRoute[];
      home: import('@elegant-router/types').LastLevelRouteKey;
    }
  }

  /**
   * namespace SystemManage
   *
   * backend api module: "systemManage"
   */
  namespace SystemManage {
    // 用户搜索参数
    interface UserSearchParams {
      /** 页码 */
      pageNo?: number;
      /** 页大小 */
      pageSize?: number;
      /** 账号 */
      account?: string;
      /** 姓名 */
      name?: string;
      [key: string]: any; // 其他可能的搜索参数
    }

    // 用户信息
    interface UserInfo {
      id: number;
      account: string;
      name: string;
      passWord: string;
      userRolesId: number[];
      status: number;
      avatar: string | null;
      tel: string;
      email: string;
      remark: string | null;
      isSuperAdmin: boolean;
      sysCreateUser: number;
      sysCreateTime: string;
      sysUpdateUser: number;
      sysUpdateTime: string;
      sysIsDelete: boolean;
    }

    // 分页数据结构
    interface UserPageList {
      pageNo: number;
      pageSize: number;
      totalPage: number;
      totalRows: number;
      records: UserInfo[];
    }

    interface RolePageList {
      pageNo: number;
      pageSize: number;
      totalPage: number;
      totalRows: number;
      records: RoleInfo[];
    }

    // 角色数据类型定义
    interface RoleInfo {
      id: number;
      name: string;
      desc: string;
      status: number;
      sysCreateUser: number;
      sysCreateTime: string;
      sysUpdateUser: number;
      sysUpdateTime: string;
      sysIsDelete: boolean;
    }
    /** role */
    type Role = Common.CommonRecord<{
      /** role name */
      roleName: string;
      /** role code */
      roleCode: string;
      /** role description */
      roleDesc: string;
    }>;

    /** role search params */
    type RoleSearchParams = CommonType.RecordNullable<
      Pick<Api.SystemManage.Role, 'roleName' | 'roleCode' | 'status'> & CommonSearchParams
    >;

    /// 角色list
    interface RoleOption {
      // id 为数字类型
      id: number;
      // name 为字符串类型
      name: string;
    }

    /** role list */
    type RoleList = RoleOption[];

    /** all role */
    type AllRole = Pick<Role, 'id' | 'roleName' | 'roleCode'>;

    /**
     * user gender
     *
     * - "1": "male"
     * - "2": "female"
     */
    type UserGender = '1' | '2';

    /** user */
    type User = Common.CommonRecord<{
      /** user name */
      userName: string;
      /** user gender */
      userGender: UserGender | null;
      /** user nick name */
      nickName: string;
      /** user phone */
      userPhone: string;
      /** user email */
      userEmail: string;
      /** user role code collection */
      userRoles: string[];
    }>;

    /**
     * menu type
     *
     * - "1": directory
     * - "2": menu
     */
    type MenuType = '1' | '2';

    type MenuButton = {
      /**
       * button code
       *
       * it can be used to control the button permission
       */
      code: string;
      /** button description */
      desc: string;
    };

    /**
     * icon type
     *
     * - "1": iconify icon
     * - "2": local icon
     */
    type IconType = '1' | '2';

    type MenuPropsOfRoute = Pick<
      import('vue-router').RouteMeta,
      | 'i18nKey'
      | 'keepAlive'
      | 'constant'
      | 'order'
      | 'href'
      | 'hideInMenu'
      | 'activeMenu'
      | 'multiTab'
      | 'fixedIndexInTab'
      | 'query'
    >;

    type Menu = Common.CommonRecord<{
      /** parent menu id */
      parentId: number;
      /** menu type */
      menuType: MenuType;
      /** menu name */
      menuName: string;
      /** route name */
      routeName: string;
      /** route path */
      routePath: string;
      /** component */
      component?: string;
      /** iconify icon name or local icon name */
      icon: string;
      /** icon type */
      iconType: IconType;
      /** buttons */
      buttons?: MenuButton[] | null;
      /** children menu */
      children?: Menu[] | null;
    }> &
      MenuPropsOfRoute;

    /** menu list */
    type MenuPage = Common.PaginatingQueryRecord<Menu>;

    type MenuTree = {
      id: number;
      label: string;
      pId: number;
      children?: MenuTree[];
    };
  }

  /** 基础资料 - 产品管理 */
  namespace Basedata {
    type ProductCategory = 'main' | 'third';

    interface ProductRecord {
      id: number;
      category: ProductCategory;
      name: string;
      version: string;
      description: string;
      status: 0 | 1;
    }

    interface ProductEnabledItem {
      id: number;
      category: ProductCategory;
      categoryLabel: string;
      name: string;
      version: string;
    }

    interface QuoterRecord {
      id: number;
      moduleName: string;
      subModuleName: string;
      description: string;
      unitPrice: number | null;
      status: 0 | 1;
    }

    interface PaymentTermRecord {
      id: number;
      name: string;
      settlementMethod: string;
      paymentRatio: number;
      node: string;
      remark: string;
      status: 0 | 1;
    }
  }
}
