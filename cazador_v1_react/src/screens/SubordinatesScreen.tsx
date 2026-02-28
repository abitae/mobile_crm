import React from 'react';
import { View, Text, TextInput, ScrollView, Pressable, StyleSheet } from 'react-native';
import { Search, UserPlus, User, MessageSquare } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../theme';
import type { Subordinate } from '../types';

interface SubordinatesScreenProps {
  filteredUsers: Subordinate[];
  search: string;
  setSearch: (v: string) => void;
  cityFilter: string;
  setCityFilter: (v: string) => void;
  cities: string[];
  onAddUser: () => void;
}

export function SubordinatesScreen({
  filteredUsers,
  search,
  setSearch,
  cityFilter,
  setCityFilter,
  cities,
  onAddUser,
}: SubordinatesScreenProps) {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Text style={styles.title}>Dateros</Text>
        <Pressable onPress={onAddUser} style={styles.addBtn}>
          <UserPlus size={18} color={colors.white} />
        </Pressable>
      </View>
      <View style={styles.searchWrap}>
        <Search size={14} color={colors.zinc[400]} style={styles.searchIcon} />
        <TextInput
          style={styles.searchInput}
          placeholder="Buscar por nombre o cargo..."
          placeholderTextColor={colors.zinc[400]}
          value={search}
          onChangeText={setSearch}
        />
      </View>
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.cityRow}>
        <Pressable onPress={() => setCityFilter('all')} style={[styles.cityChip, cityFilter === 'all' && styles.cityChipActive]}>
          <Text style={[styles.cityChipText, cityFilter === 'all' && styles.cityChipTextActive]}>Todas</Text>
        </Pressable>
        {cities.map((city) => (
          <Pressable key={city} onPress={() => setCityFilter(city)} style={[styles.cityChip, cityFilter === city && styles.cityChipActive]}>
            <Text style={[styles.cityChipText, cityFilter === city && styles.cityChipTextActive]}>{city}</Text>
          </Pressable>
        ))}
      </ScrollView>
      {filteredUsers.map((user) => (
        <View key={user.id} style={styles.card}>
          <View style={styles.cardLeft}>
            <View style={styles.avatarWrap}>
              <View style={styles.avatar}>
                <User size={20} color={colors.zinc[400]} />
              </View>
              <View style={[styles.statusDot, user.status === 'online' ? styles.statusOnline : styles.statusOffline]} />
            </View>
            <View>
              <Text style={styles.userName}>{user.name}</Text>
              <View style={styles.userMeta}>
                <Text style={styles.userRole}>{user.role}</Text>
                <Text style={styles.userCity}>{user.city}</Text>
              </View>
            </View>
          </View>
          <Pressable style={styles.msgBtn}>
            <MessageSquare size={16} color={colors.zinc[300]} />
          </Pressable>
        </View>
      ))}
      {filteredUsers.length === 0 && (
        <Text style={styles.empty}>No se encontraron dateros.</Text>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { padding: spacing.lg, gap: spacing.sm },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  title: { fontSize: 20, fontWeight: '700', color: colors.zinc[900] },
  addBtn: { padding: spacing.sm, backgroundColor: colors.blue[500], borderRadius: borderRadius.xl },
  searchWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.white,
    borderWidth: 1,
    borderColor: colors.zinc[200],
    borderRadius: borderRadius.xl,
    paddingLeft: spacing.md,
  },
  searchIcon: { marginRight: spacing.sm },
  searchInput: { flex: 1, paddingVertical: spacing.sm, paddingRight: spacing.lg, fontSize: 12 },
  cityRow: { maxHeight: 40, marginBottom: spacing.sm },
  cityChip: { paddingHorizontal: spacing.sm, paddingVertical: 8, borderRadius: borderRadius.sm, marginRight: 4 },
  cityChipActive: { backgroundColor: colors.zinc[200] },
  cityChipText: { fontSize: 10, fontWeight: '700', color: colors.zinc[500] },
  cityChipTextActive: { color: colors.zinc[900] },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: colors.white,
    padding: spacing.md,
    borderRadius: borderRadius.xl,
    borderWidth: 1,
    borderColor: colors.zinc[100],
  },
  cardLeft: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  avatarWrap: { position: 'relative' },
  avatar: {
    width: 36,
    height: 36,
    borderRadius: borderRadius.sm,
    backgroundColor: colors.zinc[50],
    alignItems: 'center',
    justifyContent: 'center',
  },
  statusDot: {
    position: 'absolute',
    bottom: -2,
    right: -2,
    width: 10,
    height: 10,
    borderRadius: 5,
    borderWidth: 2,
    borderColor: colors.white,
  },
  statusOnline: { backgroundColor: colors.emerald[500] },
  statusOffline: { backgroundColor: colors.zinc[300] },
  userName: { fontSize: 12, fontWeight: '700', color: colors.zinc[900] },
  userMeta: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  userRole: { fontSize: 10, color: colors.zinc[400] },
  userCity: { fontSize: 10, color: colors.zinc[400], fontWeight: '700' },
  msgBtn: { padding: 6 },
  empty: { textAlign: 'center', paddingVertical: spacing.xxl, fontSize: 12, color: colors.zinc[400] },
});
