import React from 'react';
import { View, Pressable, StyleSheet } from 'react-native';
import { LayoutDashboard, Users, Briefcase, Key, User } from 'lucide-react-native';
import { colors, spacing } from '../theme';
import type { AppState } from '../types';

interface BottomNavProps {
  currentState: AppState;
  onNavigate: (state: AppState) => void;
}

const tabs: { state: AppState; Icon: typeof LayoutDashboard }[] = [
  { state: 'dashboard', Icon: LayoutDashboard },
  { state: 'clients', Icon: Users },
  { state: 'projects', Icon: Briefcase },
  { state: 'reservations', Icon: Key },
  { state: 'subordinates', Icon: User },
];

const formToTab: Partial<Record<AppState, AppState>> = {
  'add-client': 'clients',
  'add-user': 'subordinates',
  'add-reservation': 'reservations',
};

export function BottomNav({ currentState, onNavigate }: BottomNavProps) {
  const activeTab = formToTab[currentState] ?? currentState;
  return (
    <View style={styles.container}>
      {tabs.map(({ state, Icon }) => {
        const isActive = activeTab === state;
        return (
          <Pressable
            key={state}
            onPress={() => onNavigate(state)}
            style={styles.tab}
          >
            <Icon
              size={24}
              color={isActive ? colors.emerald[500] : colors.zinc[400]}
            />
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    backgroundColor: colors.white,
    borderTopWidth: 1,
    borderTopColor: colors.zinc[100],
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
  },
  tab: { padding: spacing.sm },
});
