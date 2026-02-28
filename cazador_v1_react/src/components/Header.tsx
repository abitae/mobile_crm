import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { Menu, Bell, Sparkles } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../theme';

interface HeaderProps {
  onMenuPress: () => void;
}

export function Header({ onMenuPress }: HeaderProps) {
  return (
    <View style={styles.container}>
      <View style={styles.left}>
        <Pressable onPress={onMenuPress} style={styles.menuBtn} hitSlop={12}>
          <Menu size={24} color={colors.zinc[600]} />
        </Pressable>
        <View style={styles.logoRow}>
          <View style={styles.logoIcon}>
            <Sparkles size={16} color={colors.white} />
          </View>
          <Text style={styles.logoText}>Veridian</Text>
        </View>
      </View>
      <View style={styles.right}>
        <Pressable style={styles.iconBtn}>
          <Bell size={20} color={colors.zinc[400]} />
        </Pressable>
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>JD</Text>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: colors.white,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: colors.zinc[100],
  },
  left: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  menuBtn: { padding: spacing.sm, marginLeft: -spacing.sm },
  logoRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  logoIcon: {
    width: 32,
    height: 32,
    borderRadius: borderRadius.sm,
    backgroundColor: colors.emerald[500],
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoText: { fontWeight: '700', fontSize: 14, color: colors.zinc[900] },
  right: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  iconBtn: { padding: spacing.sm },
  avatar: {
    width: 32,
    height: 32,
    borderRadius: borderRadius.full,
    backgroundColor: colors.blue[100],
    borderWidth: 1,
    borderColor: colors.blue[200],
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarText: { fontSize: 12, fontWeight: '700', color: colors.blue[600] },
});
