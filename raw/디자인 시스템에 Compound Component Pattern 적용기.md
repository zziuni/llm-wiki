---
title: "디자인 시스템에 Compound Component Pattern 적용기"
source: "https://medium.com/corca/%EB%94%94%EC%9E%90%EC%9D%B8-%EC%8B%9C%EC%8A%A4%ED%85%9C%EC%97%90-compound-component-pattern-%EC%A0%81%EC%9A%A9%EA%B8%B0-020c68df289e"
author:
  - "[[Corca]]"
published: 2024-07-09
created: 2026-04-09
description: "디자인 시스템에 Compound Component Pattern 적용기 Written by: 손도희(Frontend Engineer), 홍승연(Frontend Engineer) Intro 안녕하세요. 코르카 프론트엔드 팀의 손도희 …"
tags:
  - "clippings"
---
[Sitemap](https://medium.com/sitemap/sitemap.xml)

Get unlimited access to the best of Medium for less than $1/week.[Become a member](https://medium.com/plans?source=upgrade_membership---post_top_nav_upsell-----------------------------------------)

[Become a member](https://medium.com/plans?source=upgrade_membership---post_top_nav_upsell-----------------------------------------)

## [Corca](https://medium.com/corca?source=post_page---publication_nav-66a4ff2060a1-020c68df289e---------------------------------------)

[![Corca](https://miro.medium.com/v2/resize:fill:38:38/1*FTjc9qKVIusTHEUnqyHFTw.png)](https://medium.com/corca?source=post_page---post_publication_sidebar-66a4ff2060a1-020c68df289e---------------------------------------)

기술 발전의 혜택을 모두가 누리게 하여 인류 문명의 발전에 기여하는 코르카

> Written by: 손도희(Frontend Engineer), 홍승연(Frontend Engineer)

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*ok1ovKVQtJ-0v5WB7BY5rg.png)

## Intro

안녕하세요. 코르카 프론트엔드 팀의 손도희, 홍승연 입니다.

이번 글에서는 디자인 시스템 구축 및 발전 과정에서 겪은 합성 컴포넌트 디자인 패턴 도입기를 다루어보려고 합니다.

프론트엔드 팀에서는 디자인 시스템 구축 과정에서 테이블 컴포넌트 개발에 많은 고민을 했습니다. 자주 사용되며, 다양한 기능과 향후 확장성을 고려해야 했기 때문입니다.

기존 테이블 컴포넌트는 Control Props 패턴을 이용했기에, 컴포넌트 내부 로직이 복잡해져 가독성과 확장성이 떨어지는 문제가 있었습니다.

이를 해결하기 위해 Compound Component 패턴을 적용했습니다. 이 패턴은 컴포넌트를 작은 단위로 분리하고, 분리된 컴포넌트를 조합하여 컴포넌트를 만들 수 있게끔 해줍니다. 이를 통해 역할을 분산시키고 추상화 레벨을 적절하게 낮춤으로써 확장성과 가독성을 높일 수 있었습니다.

이 글에서는 코르카 디자인 시스템(Corca Design System, CDS)의 테이블 컴포넌트를 구축하고 발전시켜 나가는 과정에서 복잡한 UX/UI 요구 사항을 만족시키기 위해 Compound Component 패턴을 도입했던 경험과 구현 방식을 공유하고자 합니다.

## 추가되는 요구사항, 복잡해지는 컴포넌트

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*7FO_--Maz0KQ3Ss5VXzg0A.png)

이해를 돕기 위한 예시 이미지 입니다. 코르카 디자인 시스템(CDS)의 스토리북 이미지 입니다.

위 사진은 자사 테이블 컴포넌트 디자인 입니다. 해당 테이블 컴포넌트가 충족해야 하는 주요 요구사항은 아래와 같습니다.

1. Th와 Td의 높이를 조정할 수 있는 사이즈 옵션이 필요합니다.
2. Th와 Td에 아이콘 및 다양한 종류의 컴포넌트(배지, 셀렉트 인풋, 스위치, 체크박스 등)를 렌더링할 수 있어야 합니다.
3. 필수 입력 Th의 경우 빨간색 별표(asterisk)를 표시해야 합니다.
4. Td의 패딩 값과 정렬 옵션은 데이터 유형에 따라 다르게 설정되어야 합니다.
5. Td의 너비는 fill 또는 사용 위치에서 지정 가능해야 합니다.

요구 사항이 상당히 복잡하죠? 이 컴포넌트를 어떻게 구현할 수 있을까요?

일반적으로 컴포넌트를 구현할 때는 props를 전달하여 구현체를 만듭니다. 상위 컴포넌트에서 props를 전달받아 하위 구성 요소를 구현하는 방식을 Control Props 패턴이라고 합니다.

기존 테이블 컴포넌트는 Control Props 패턴을 이용해 아래 코드처럼 구현했습니다.

```hs
interface Props {
  format: {
    key: string;
    withAsterisk?: boolean;
    tableHeader: {
      component: () => ReactElement;
    }
    tableData: {
     type: 'image' | 'text' | 'icon' ...
     component: () => ReactElement;
    }
  }[];
  width?: number;
  height: 'l' | 'm' | 's';
}
function Table({ format, width, height }: Props) {
  return (
    <Table>
      <Tbody>
        {format.map(({ key, withAsterisk, tableHeader, tableData }) => {
          const { component: TableHeader} = tableHeader;
          const { type: tdType, component: TableData } = tableData;
          return (
            <Tr key={key}>
              <Th width={width}>
                <TableHeader />
                {withAsterisk && <Star />}
              </Th>
              <Td type={tdType}>
                <TableData />
              </Td>
            </tr>
          );
        })}
      </Tbody>
    </Table>
  );
}
```

위 코드를 보면 전달해야 하는 props가 상당히 많다는 것을 알 수 있습니다. 이렇게 되면 각 prop이 컴포넌트 내부에서 어떤 역할을 하는지 사용자가 추측하기 어려워집니다.

해당 컴포넌트는 구현 이후 여러 차례의 요구 사항 추가 및 변경을 겪으며 많이 수정되었습니다. 그 과정에서 props가 계속 추가되고, 이에 따른 분기 처리가 증가하면서 내부 로직이 매우 복잡해졌습니다. 결과적으로 컴포넌트가 너무 많은 역할을 수행하게 되어, 새로운 기능을 추가하기가 힘들어졌습니다.

그렇다면, 왜 이 테이블 컴포넌트는 확장성이 떨어지고 이해하기 어렵게 되었을까요?

그 이유는 하나의 컴포넌트가 너무 많은 역할을 수행하고 있기 때문입니다. 요구 사항이 복잡하거나 변경 가능성이 높은 컴포넌트가 너무 많은 역할을 수행하게 되면 이를 관리하기가 어려워집니다. 이는 컴포넌트의 유연성과 재사용성을 저하시킵니다. 다양한 상황에 쉽게 대응할 수 있도록 설계되지 않았기 때문에, 새로운 기능을 추가할 때 기존 코드와 호환되게 수정하기 어렵습니다.

따라서 이 테이블 컴포넌트의 구조를 변경하여, 더 유연하고 확장성있게끔 만들어야 합니다.

코르카 프론트엔드 팀은 이러한 문제를 해결하기 위해 Compound Component 패턴을 도입했습니다. 이 패턴을 통해 테이블 컴포넌트를 여러 개의 작은 컴포넌트로 분리하여, 각 부분 컴포넌트가 단일 책임 원칙을 준수하도록 구현했습니다. 이를 통해 컴포넌트의 유연성과 재사용성을 높여 다양한 요구 사항을 더 쉽게 반영할 수 있었습니다.

## 조합을 통해 구현체에 유연성을 불어 넣자!

관리가 어려워진 컴포넌트의 props를 걷어내며 컴포넌트 설계를 변경했습니다.

Table 혹은 하나의 Text Input 창에서도 ui 디자인 요구 사항이 세분화되며 채택하게 되었습니다.

합성 컴포넌트 패턴은 컴포넌트 간의 계층 구조가 명확하고 코드 재사용성을 향상시킬 수 있기에 적합했습니다.

## 합성 컴포넌트 패턴 Compound Component Pattern

- 합성 컴포넌트 패턴 Compound Component Pattern이란?

> ***What are Compound Components?***
> 
> *Compound components are a React pattern that provides an expressive and flexible way for a parent component to communicate with its children, while expressively separating logic and UI.*
> 
> [*출처 — Better Programming*](https://betterprogramming.pub/compound-component-design-pattern-in-react-34b50e32dea0)

합성 컴포넌트 패턴은 하나의 완결된 UI 컴포넌트를 위해서 작게 세분화된 하위 컴포넌트(Sub Component)가 존재하고, 그 하위 컴포넌트(Sub Component)들을 조합하여 사용하는 디자인 패턴입니다. 하위 컴포넌트들과, 하위 컴포넌트들 활용하는 메인 컴포넌트에서는 상태(state)와 로직을 공유합니다.

메인 컴포넌트에서 활용하는 하위 컴포넌트들은 기능 단위로만 나누어지지 않으며 상황에 따라 액션, UI 등 다른 기준으로 나뉘어 조합될 수 있습니다. 하지만 재사용성을 극대화하기 위해 **하위 컴포넌트는 단일 책임 원칙(SRP)에 따라 하나의 책임 · 역할만 맡아야합니다.**

합성 컴포넌트 패턴을 적용하더라도 컴포넌트가 너무 여러가지 책임을 지게 된다면, 요구사항이 추가될때 마다 (피를 볼 수 있습니다) 처음부터 새로 짜야할 수 있습니다.

합성 컴포넌트에 대해 설명을 들어도 잘 안 와닿는 다고요?

모든 분들이 자주 접하는 드롭다운 메뉴를 대표적인 합성 컴포넌트 예시로 꼽을 수 있습니다. 드롭다운 메뉴를 구현하기 위해 프론트엔드 개발자라면 누구나 사용해봤을 [HTML select element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element#forms) 는, **select 컴포넌트가 option 컴포넌트를 활용하여 드롭다운 메뉴를 완성시키는 합성 컴포넌트** 입니다.

![](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*_IuJ2q8eCm1Tx_9_1A5RhA.gif)

```hs
<label for="lunch-select">Luch Menu:</label>
<select name="lunch" id="lunch-select">
  <option value="">--choose a lunch option--</option>
  <option value="poke">Poke</option>
  <option value="ramen">Ramen</option>
  <option value="sushi">Sushi</option>
  <option value="jaeyook">Jaeyoook</option>
</select>
```

메인 컴포넌트인 select 컴포넌트는 UI · 로직에 대한 관심사를 가지고 있습니다. 반면 서브 컴포넌트인 option은 오로지 value에 대한 관심사를 가지고 있습니다.

select 컴포넌트와 option 컴포넌트가 함께 사용되고 select 컴포넌트가 option 컴포넌트를 서브 컴포넌트로 활용함으로써, 드롭다운 메뉴가 완성됩니다!

이런 Compound Component Pattern을 도입해서 테이블 컴포넌트를 구현했을지 세부적으로 소개해보겠습니다.

## Corca Design System Table에 합성 컴포넌트 패턴 도입

Corca Design System에서는 합성 컴포넌트 패턴을 적용하며 Table을 다음과 같이 구성했습니다.

```hs
import { TableContainer } from './TableContainer';
import { Tbody } from './Tbody';
import Td from './Td';
import Th from './Th';
import { Thead } from './Thead';
import { Tr } from './Tr';

const Table = { Container: TableContainer, Thead, Th, Tbody, Tr, Td } as const;

export default Table;
```

**Container(TableContainer)는 “하나의 컴포넌트가 완성되기 위해 분리된 서브 컴포넌트를 조합하여 활용하는 측인” 메인 컴포넌트입** 니다. 기본 HTML 테이블 규칙과 동일하게 모든 테이블 콘텐츠는 `<table></table>` 태그 내에 존재해야 합니다.

```hs
//Table.tsx

import styled from '@emotion/styled';
import { ReactNode } from 'react';

export const TableContainer = ({ children }: { children: ReactNode }) => {
  return <Table>{children}</Table>;
};

const Table = styled.table\`
  display: table;
  width: 100%;
  text-align: left;
  ...(생략)...
\`;
```

메인 컴포넌트인 Table 컴포넌트가 조합하여 사용할 수 있는 서브 컴포넌트는 `Thead, Th, Tbody, Tr, Td` 로 구성되어있습니다.

이 중에서 특히 Th 컴포넌트와 Td 컴포넌트에 대한 UI/UX 명세가 복잡했습니다.

테이블 사이즈가 s/m/l 3가지가 필요하기도 했고, 테이블 헤드가 s(small)이면서 테이블 로우 데이터(테이블에서 헤드를 제외한 행을 의미)가 l(large)인 상황과 같이 다양한 디자인 조합이 요구되는 상황이었습니다.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*2GlpmoCDt2ft9--m9KfNtg.png)

Th 컴포넌트 이미지 예시

서브컴포넌트인 Th컴포넌트는 테이블 컴포넌트의 다른 하위 컴포넌트들과 달리, s/m/l 사이즈 외에도 특징적인 디자인 요구사항이 있습니다.

> *테이블 헤드(Th 컴포넌트)에 대한 디자인 요구사항*
> 
> 1\. 아이콘이 optional하게 추가될 수 있음  
> 2\. 테이블 사이즈에 따라서 아이콘 사이즈도 달라야하고 테이블 사이즈별 icon사이즈는 fix되어있음  
> 3\. 테이블 헤드는 두 가지 컴포넌트 종류가 필요. check box를 위한 컴포넌트와 text를 위한 컴포넌트  
> 4\. 테이블 헤드에 check box가 들어가는 경우에는 텍스트가 들어간 경우와 padding값이 달라야함

이런 모든 요구사항은 처음부터 확정된 것이 아니며 시간에 따라 점진적으로 추가되었습니다.

처음에는 1번 요구사항과 3번 요구사항만 존재 했었습니다.

하지만 합성 컴포넌트 패턴에 따라 적절히 하위 컴포넌트를 더 분할하여 확장성 있게 요구사항 추가에 대응할 수 있었습니다.

Th 컴포넌트를 다음과 같이 개발했습니다.

```typescript
import { ReactElement, ReactNode, cloneElement } from 'react';
import styled from '@emotion/styled';
import { FixedCellType, type TdSizeType } from './Td';
import { Checkbox, type CheckboxProps } from '../Checkbox';
import { B4, B6, type Text } from '../Text';

const TABLE_TH_STYLE: TableThStyleType = {
  l: {
    height: 46,
    iconSize: 20,
    textComponent: B4,
  },
  m: {
    height: 40,
    iconSize: 18,
    textComponent: B4,
  },
  s: {
    height: 32,
    iconSize: 16,
    textComponent: B6,
  },
};

export interface Props {
  text: string;
  icon?: ReactNode;
  width?: string;
  size: ThSizeType;
}

export const DefaultTh = ({ text, icon, size, width = 'auto' }: Props) => {
  const thStyle = TABLE_TH_STYLE[size];
  return (
    <TableDefaultHeader width={width} height={thStyle.height}>
      <ThContents>
        <thStyle.textComponent>{text}</thStyle.textComponent>
        {icon &&
          cloneElement(icon as ReactElement, {
            size: thStyle.iconSize,
          })}
      </ThContents>
    </TableDefaultHeader>
  );
};

export const CheckboxTh = ({
  size,
  checkboxType,
}: {
  size: ThSizeType;
  checkboxType: CheckboxProps;
}) => {
  const thStyle = TABLE_TH_STYLE[size];
  return (
    <CheckboxTableHeader
      width={FIXED_TH_WIDTH[FixedCellType.CHECKBOX][size]}
      height={thStyle.height}
    >
        <Checkbox {...checkboxType} />
    </CheckboxTableHeader>
  );
};

const Th = {
  Default: DefaultTh,
  Checkbox: CheckboxTh,
} as const;

export default Th;

const ThContents = styled.div\`
  display: flex;
  align-items: center;
  gap: 2px;
\`;

const TableHeader = styled.th<{ width: string; height: number }>\`
  width: ${({ width }) => width};
  height: ${({ height }) => height}px;
  vertical-align: middle;
  text-wrap: nowrap;
\`;

const TableDefaultHeader = styled(TableHeader)\`
  padding: 5px 14px;
\`;

const CheckboxTableHeader = styled(TableHeader)\`
  padding: 5px 12px 5px 18px;
\`;
```

\*\*\*나머지 테이블 서브 컴포넌트 코드는 [코르카 디자인 시스템](https://github.com/corca-ai/cds) 에서 직접 확인해보실 수 있습니다.

## CDS 테이블의 실제 적용 사례

코르카 디자인 시스템 테이블이 실제로 프로젝트에서 어떻게 쓰일 수 있는지 확인해보면 합성 컴포넌트 패턴을 통해 얼마나 유연하게 대응할 수 있는 지 확인할 수 있습니다.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*rXtQwUzf6hdCgaO492bNmA.png)

이해를 돕기위한 이미지로 테이블 헤더의 Sort 버튼이 hover된 예시입니다. 예시를 위한 이미지로 일부 코드와 다른 부분이 있을 수 있습니다.

다음의 코드를 살펴보면, 모든 요구 사항을 props로 받고 있지 않은 것을 확인할 수 있습니다. 와이어프레임에 따라 원하는 테이블 UI를 그려내기 위해 여러 하위 컴포넌트들이 조합되고 있는 것을 확인할 수 있습니다.

```ts
// CampaignListTable.tsx

import Table from '@corca-ai/design-system';
import {
  CampaignListTableBody,
  CampaignListTableBodyProps,
} from './CampaignListTableBody';
import {
  CampaignTableHeader,
  CampaignTableHeaderProps,
} from './CampaignListTableHeader';

export type CampaignListTableProps = CampaignListTableBodyProps &
  CampaignTableHeaderProps;

export function CampaignListTable({
  campaigns,
  onChangeActive,
  sorts,
}: CampaignListTableProps) {
  return (
    <Table.Container>
      <CampaignTableHeader sorts={sorts} />
      <CampaignListTableBody
        campaigns={campaigns}
        onChangeActive={onChangeActive}
      />
    </Table.Container>
  );
}
```


```ts
//CampaignTableHeader.tsx

import { useTranslation } from 'next-i18next';
import Table from '@corca-ai/design-system';
import { CampaignSortOption } from '@lib/types/query-definition.type';
import { UseSortReturn } from '../../../../lib/types/common/sort';
import { SortButton } from '../../../common/button/SortButton';

const TH_SIZE = 'm';

export interface CampaignTableHeaderProps {
  sorts: UseSortReturn<CampaignSortOption>;
}

export function CampaignTableHeader({
  sorts: { sort, onSort },
}: CampaignTableHeaderProps) {
  const { t } = useTranslation(['common']);
  return (
    <Table.Thead>
      <Table.Tr>
        <Table.Th.Default
          width="193px"
          size={TH_SIZE}
          text={t('이미지')}
        />
        <Table.Th.Default
          width="350px"
          size={TH_SIZE}
          text={t('캠페인 이름')}
          icon={
            <SortButton
              sort={sort.title}
              onClick={() => onSort(CampaignSortOption.TITLE)}
            />
          }
        />
        <Table.Th.Default
          width="300px"
          text={t('지면')}
          size={TH_SIZE}
          icon={
            <SortButton
              sort={sort.placementTitle}
              onClick={() => onSort(CampaignSortOption.PLACEMENT_TITLE)}
            />
          }
        />
        <Table.Th.Default
          width="315px"
          text={t('캠페인 기간')}
          size={TH_SIZE}
          icon={
            <SortButton
              sort={sort.startsAt}
              onClick={() => onSort(CampaignSortOption.STARTS_AT)}
            />
          }
        />
        <Table.Th.Default
          width="120px"
          size={TH_SIZE}
          text={t('활성/비활성', { ns: 'common' })}
          icon={
            <SortButton
              sort={sort.activated}
              onClick={() => onSort(CampaignSortOption.ACTIVATED)}
            />
          }
        />
      </Table.Tr>
    </Table.Thead>
  );
}
```


컴포넌트를 조합하여 사용하는 방식의 장점은 특히 Td 컴포넌트에서 잘 들어납니다. 짧게 td 태그에 대해서 설명 드리자면, HTML 테이블에서 하나의 데이터 셀(data cell)을 정의할 때 사용되는 태그랍니다.

Td 컴포넌트는 가장 디자인 요구사항이 복잡한 컴포넌트였습니다.


데이터 셀에 들어가는 아이템 종류(e.g. text, image, icon, button 등)에 따라서 padding, width, ellipsis, vertical-align 등이 모두 달랐습니다.

처음에는 2가지 종류의 디자인의 데이터 셀만 존재했지만 하나씩 추가된 데이터 셀 디자인은 최종으로 8가지가 되었습니다.

합성 컴포넌트 디자인 패턴을 적용하기 전에는 하나의 Td 컴포넌트로 모든 사항을 props로 입력받아 처리하도록 개발 했습니다. 하지만 다른 종류의 데이터 셀 개발을 요청 받을 때마다 최초로 개발된 Td 컴포넌트를 수정하며 코드 확장성의 한계를 경험할 수 있었습니다. 또한 과도한 props의 개수는 DX(Developer Experience)를 저하했습니다. 따라서 테이블 컴포넌트가 필요한 상황에서 적합한 하위 컴포넌트를 조합하여 사용하도록 `TextTd, ImgTd, BadgeTd, SwitchTd, SelectTd, CheckboxTd, RadioTd, IconTd` 로 컴포넌트 별 역할을 분리하여 개발했습니다.


**😎 이제 또 다른 데이터 셀 컴포넌트 디자인 요청이 들어오더라도 두렵지 않습니다. 000Td 컴포넌트만 개발하여 추가하고, 기존 코드는 전혀 수정할 필요가 없기 때문이죠!**

Td 컴포넌트가 어떻게 프로젝트에서 사용되는지 아래 코드에서 확인해보실 수 있습니다.


```ts
import { useTranslation } from 'next-i18next';
import { useRouter } from 'next/router';
import { Switch, Table } from '@corca-ai/design-system';
import { FetchManyCampaignsResponseDto } from '@lib/api/controller/v1.0';
import { useNotification } from '../../../../lib/store/notifications';
import { PageURL } from '../../../../lib/types/common/url';
import { formatCampaignPeriod } from '../../../../lib/util/campaign/period';

const TD_SIZE = 's';

export interface CampaignListTableBodyProps {
  campaigns: FetchManyCampaignsResponseDto[];
  onChangeActive: (id: string, activated: boolean) => void;
}

export function CampaignListTableBody({
  campaigns,
  onChangeActive,
}: CampaignListTableBodyProps) {
  const { t } = useTranslation(['common']);
  const router = useRouter();
  const { showConfirmModal } = useNotification();

return (
    <Table.Tbody>
      {campaigns.map(
        ({ id, placement, title, activated, startsAt, endsAt }) => (
          <Table.Tr
            cursorPointer
            key={id + 'CampaignItems'}
            onClick={() => {
              router.push(\`${PageURL.CAMPAIGN}/${id}`);
            }}
          >
            <Table.Td.Img size={TD_SIZE} src={image} />
            <Table.Td.Text width={350} size={TD_SIZE} ellipsis>
              {title}
            </Table.Td.Text>
            <Table.Td.Text width={300} size={TD_SIZE} ellipsis>
              {placement.title}
            </Table.Td.Text>
            <Table.Td.Text width={315} size={TD_SIZE} ellipsis>
              {formatCampaignPeriod({
                startsAt,
                endsAt,
                labelForWithoutEnd: t('withoutEndDate', {
                  ns: 'common',
                }),
                language: router.locale,
              })}
            </Table.Td.Text>
            <Table.Td.Switch size={TD_SIZE}>
              <div onClick={(e) => e.stopPropagation()}>
                <Switch
                  checked={activated}
                  onChange={() => {
                      showConfirmModal();
                  }}
                />
              </div>
            </Table.Td.Switch>
          </Table.Tr>
        )
      )}
    </Table.Tbody>
  );
}
```

기획과 디자인 명세가 복잡한 컴포넌트였지만 코르카 디자인 시스템의 테이블은, 어떤 아이템이 데이터셀이 테이블에 포함 되더라도 **데이터 별 성격을 분석하여 최적의 UI/UX를 제공하고 데이터 가독성을 높이는 컴포넌트** 라고 자부합니다.

적절한 padding, 다양한 size, 그리고 데이터 셀 내에서 아이템별 최적의 위치를 구현한 코르카 디자인 시스템 테이블은 **아름다움만을 위한 디자인이 아닌, 페이지 내 수많은 데이터가 한눈에 읽히는 User Centric한 디자인 컴포넌트** 입니다.

## 합성 (Composition) vs 상속 (Inheritance)

이번 코르카 디자인 시스템 컴포넌트에 상속이 아닌 합성이 더 적합했던 것은 결코 우연이 아닙니다.

유지보수가 필요 없고, 기획이 변하지 않으며, MVP 개발만 필요한 경우였다면 모든 프로퍼티를 상속받도록 하여 컴포넌트 개수를 줄이고, 컴포넌트를 사용하는 상황에서의 코드 복잡도도 낮출 수 있었겠죠.

하지만 리액트 공식 문서를 보면, 재사용성 극대화를 위해 상속보다 합성을 권유하는 것을 확인 할 수 있습니다.

> *React has a powerful composition model, and we recommend using composition instead of inheritance to reuse code between components.*
> 
> React는 강력한 합성 모델을 가지고 있으며, 상속 대신 합성을 사용하여 컴포넌트 간에 코드를 재사용하는 것이 좋습니다.

리액트의 철학 또한 잘 나타나는 구절이네요.

합성과 상속을 비교하여 간단히 알아보고 글을 마치도록 하겠습니다.

## 상속 Inheritance

상속은 객체지향 프로그래밍(OOP)의 중요한 4개 특징 중 하나 입니다. 상속과 합성(Composition, OOP에서는 조합으로 불리기도 합니다.)은 모두 객체들의 관계를 나타내는 중요한 개념입니다.

```ts
class Mobile {
    brand: string;
    model: string;
        
constructor(brand: string, model: string) {
        this.brand = brand;
        this.model = model;
    }

getDetails(): string {
        return ${this.brand} ${this.model};
    }
}

// Apple은 Mobile 클래스를 상속합니다.
class Apple extends Mobile {
    osVersion: string;

constructor(model: string, osVersion: string) {
        super('Apple', model);
        this.osVersion = osVersion;
    }

getOsVersion(): string {
        return iOS ${this.osVersion};
    }
}

const myPhone = new Apple('iPhone 14', '17.0');
console.log(myPhone.getDetails());   // 출력: Apple iPhone 14
console.log(myPhone.getOsVersion()); // 출력: iOS 17.0
```

상속은 클래스 간의 부모-자식 관계를 정의하고 부모 클래스의 메서드와 속성을 자식 클래스에서 재사용 가능하도록 해줍니다. 일부 기능을 재사용할 수 있을 뿐만 아니라 자식 클래스에서 일부 추가 하거나 재정의함으로써 쉽게 코드를 확장할 수 있습니다. 따라서 `is-a 관계` 로 표현할 수 있습니다.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*r-iubeOWeTH-oVP8RU-xbQ.png)

출처 [https://www.adservio.fr/post/composition-vs-inheritance](https://www.adservio.fr/post/composition-vs-inheritance)

상속된 자식 클래스는 부모 클래스의 코드 자체를 물려받아 재사용하며 부모 클래스의 결합도가 높습니다. 자식 클래스가 부모 클래스에게 의존성이 높기때문에 변화에 대처하기 어려울때가 많습니다.

또한 불필요한 기능과 인터페이스가 상속되고, 잘못 사용했을때는 클래스 폭발(class explosion) 문제가 있을 수 있습니다. 부모 클래스의 구현이 자식 클래스에게 노출되는 상속은 캡슐화를 깨뜨리기도 합니다.

따라서 명확한 `is-a 관계` 에 있는 경우 사용하는 것이 적절합니다.

## 합성 Composition

상속은 `is-a 관계` 로 나타낼 수 있다면, 합성은 `has-a관계` 로 표현할 수 있습니다. 필드로 클래스의 인스턴스를 참조하도록 하는 설계 방식입니다. 서로 연관성이 없는 클래스들의 관계에서 하나의 클래스가 다른 클래스를 사용하여 구현해야하는 상황으로 설명할 수도 있습니다. 합성은 상속과 달리 클래스들이 독립적입니다. 하나의 클래스가 전략에 따라 다른 클래스를 일부 이용할 수 있지만 또 다른 클래스로도 대체 가능한 관계입니다.

따라서 합성을 통해 클래스간 결합도를 낮출 수 있습니다. 또한 상속 관계에 비해 부모 클래스에 의존하지 않기에 변화에 유연하게 대처할 수 있습니다.

합성은 객체 간의 관계가 상속과 달리 수직 관계가 아닌 수평적인 관계입니다.

A 클래스가 B 클래스의 기능이 필요한 경우에 꼭 상속하지 않는 대신 클래스 인스턴스 변수에 저장하여 사용하는 방식입니다.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*tOEgLBf-nMWwAvDfz4Om5A.png)

출처 — [https://www.adservio.fr/post/composition-vs-inheritance](https://www.adservio.fr/post/composition-vs-inheritance)

```ts
class Engine {
    engineType: string;

constructor(type: string) {
        this.engineType = type;
    }
}

class Car {
    engine: Engine;

constructor(engine: Engine) {
        this.engine = engine; // [has-a] Initialize class field in constructor
    }

drive() {
        console.log(\`${this.engine.engineType} 엔진으로 드라이브 실행.`);
    }

brakes() {
        console.log(\`${this.engine.engineType} 엔진으로 브레이크 실행.`);
    }
}

const myEngine = new Engine("Gasoline");
const myCar = new Car(myEngine);

myCar.drive();   // 출력: Gasoline 엔진으로 드라이브 실행.
myCar.brakes();  // 출력: Gasoline 엔진으로 브레이크 실행.

const myEngine = new Engine("Diesel");
const myCar = new Car(myEngine);

myCar.drive();   // 출력: Diesel 엔진으로 드라이브 실행.
myCar.brakes();  // 출력: Diesel 엔진으로 브레이크 실행.
```

상황에 따라서 상속이나 합성 중 특정 한가지가 더 적합한 경우가 있을 수 있으니,

**오버엔지니어링 혹은 언더엔지니어링이 되지 않도록 적절히 결정하는 것이 중요하겠죠?**

짧게 합성과 상속에 대해서도 알아보며 합성 컴포넌트 디자인 패턴에 대한 이해를 넓혀보았습니다.

## 결론

프로덕트를 개발하다 보면 컴포넌트의 요구사항이 변경되는 경우가 많습니다. 이를 충족하기 위해 단일 컴포넌트의 props 개수를 늘리다 보면 코드가 복잡해지고 레거시가 되어버리곤 합니다.

그래서 요구사항이 복잡하거나 변경 가능성이 높은 컴포넌트는 유연성과 확장성을 고려하여 구현해야 합니다. 이 경우 Compound Component 패턴을 활용하는 것은 어떨까요? 해당 패턴을 사용하면 컴포넌트를 작은 단위로 분리하여 조합할 수 있어 직관적이며, 코드의 재사용성과 확장성이 높아집니다. 또한, 컴포넌트 간의 의존성을 낮출 수 있어 유지보수가 용이합니다.

다만 모든 컴포넌트가 유연성과 확장성을 가질 필요는 없습니다. 요구사항이 제한적이고 단순한 컴포넌트라면 Control Props 패턴을 사용하여 구현하는 것이 더 직관적일 수 있습니다. 따라서 컴포넌트의 복잡도와 요구사항에 따라 적절한 패턴을 선택하는 것이 중요합니다.

이 글이 유사한 문제 상황을 직면하고 있는 개발자들에게 도움이 되기를 바랍니다.

감사합니다.

[![Corca](https://miro.medium.com/v2/resize:fill:48:48/1*FTjc9qKVIusTHEUnqyHFTw.png)](https://medium.com/corca?source=post_page---post_publication_info--020c68df289e---------------------------------------)

[![Corca](https://miro.medium.com/v2/resize:fill:64:64/1*FTjc9qKVIusTHEUnqyHFTw.png)](https://medium.com/corca?source=post_page---post_publication_info--020c68df289e---------------------------------------)

[Last published Mar 18, 2026](https://medium.com/@sunny_37651/%EC%BD%94%EB%A5%B4%EC%B9%B4-ax-day-c32cbd443c2f?source=post_page---post_publication_info--020c68df289e---------------------------------------)

기술 발전의 혜택을 모두가 누리게 하여 인류 문명의 발전에 기여하는 코르카

[![Corca](https://miro.medium.com/v2/resize:fill:48:48/1*SR3Eo07nJm0FZ-Gaz7GZ7g.png)](https://medium.com/@sunny_37651?source=post_page---post_author_info--020c68df289e---------------------------------------)

[![Corca](https://miro.medium.com/v2/resize:fill:64:64/1*SR3Eo07nJm0FZ-Gaz7GZ7g.png)](https://medium.com/@sunny_37651?source=post_page---post_author_info--020c68df289e---------------------------------------)

[5 following](https://medium.com/@sunny_37651/following?source=post_page---post_author_info--020c68df289e---------------------------------------)